module UserValidations
  extend ActiveSupport::Concern

  included do
    # User information validations
    validates :first_name, :last_name, presence: true, length: { minimum: 2, maximum: 50 }

    # Email format validation (additional to Devise's validation)
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }

    # Custom validation for profile picture
    validate :validate_profile_picture, if: :profile_picture_attached?

    # Password validation for security
    validate :password_complexity, if: -> { password.present? }
  end

  private

  def profile_picture_attached?
    profile_picture.attached?
  end

  # Fallback validation for profile picture when active_storage_validations gem is not available
  def validate_profile_picture
    if profile_picture.attached?
      # Check file size
      if profile_picture.blob.byte_size > 5.megabytes
        errors.add(:profile_picture, "must be less than 5MB")
        profile_picture.purge
      end

      # Check content type
      allowed_types = [ "image/png", "image/jpeg", "image/jpg", "image/webp" ]
      unless allowed_types.include?(profile_picture.blob.content_type)
        errors.add(:profile_picture, "must be a valid image format (JPEG, PNG, or WebP)")
        profile_picture.purge
      end
    end
  end

  def password_complexity
    # Skip validation if password is blank (handled by Devise) or meets requirements
    return if password.blank? ||
              password =~ /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/

    errors.add(:password, "must include at least one lowercase letter, one uppercase letter, one digit, one special character, and be at least 8 characters long")
  end
end
