class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable, :lockable,
         :recoverable, :rememberable, :validatable, :timeoutable, :trackable

  # Active Storage for profile picture
  has_one_attached :profile_picture

  # --- Associations ---

  # Customer relationships
  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error
  has_many :reviews, dependent: :nullify
  has_many :wishlist_items, dependent: :destroy
  has_many :download_links, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :payment_audit_logs, dependent: :nullify
  has_many :user_activities, dependent: :destroy
  has_many :action_items, dependent: :destroy

  # Seller relationship
  has_one :seller, dependent: :destroy

  # --- Enums ---

  # User roles (if you have a role column)
  # enum :role, { customer: 0, seller: 1, admin: 2, super_admin: 3 }, default: :customer

  # Account status
  # enum :status, { inactive: 0, active: 1, suspended: 2 }, default: :active

  # User preferences
  store_accessor :preferences, :theme, :email_notifications, :marketing_emails,
                :two_factor_enabled, :currency_preference, :language_preference

  # --- Validations ---

  # User information validations
  validates :first_name, :last_name, presence: true, length: { minimum: 2, maximum: 50 },
                                    allow_blank: true  # Allow blank for now to prevent validation errors

  # Email format validation (additional to Devise's validation)
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }

  # Custom validation for profile picture
  validate :validate_profile_picture, if: :profile_picture_attached?

  # --- Callbacks ---

  # Create a cart for new users
  after_create :create_cart

  # Set default preferences
  after_initialize :set_default_preferences, if: :new_record?

  # --- Delegations ---

  # Check if user is a seller
  delegate :present?, to: :seller, prefix: true, allow_nil: true

  # --- Methods ---

  # Role checking methods
  def admin?
    super_admin? || admin
  end

  def super_admin?
    super_admin == true
  end

  def seller?
    seller_present?
  end

  # Status methods (uncomment if you add a status column)
  # def active_for_authentication?
  #   super && active?
  # end
  #
  # def inactive_message
  #   active? ? super : :account_inactive
  # end

  # User name and display methods
  def full_name
    [ first_name, last_name ].compact.join(" ").presence || email.split("@").first
  end

  def display_name
    full_name
  end

  def initials
    [ first_name&.first, last_name&.first ].compact.join("").upcase.presence || email.first.upcase
  end

  # User avatar/profile picture methods
  def avatar_url
    if profile_picture.attached?
      profile_picture
    else
      gravatar_url
    end
  end

  def profile_picture_thumbnail
    return gravatar_url(size: 50) unless profile_picture.attached?

    profile_picture.variant(resize_to_fill: [ 50, 50 ])
  end

  def profile_picture_medium
    return gravatar_url(size: 300) unless profile_picture.attached?

    profile_picture.variant(resize_to_limit: [ 300, 300 ])
  end

  def gravatar_url(options = {})
    size = options[:size] || 200
    default = options[:default] || "identicon"

    hash = Digest::MD5.hexdigest(email.downcase)
    "https://www.gravatar.com/avatar/#{hash}?s=#{size}&d=#{default}"
  end

  # User activity tracking
  def last_active_at
    [ last_sign_in_at, updated_at ].compact.max
  end

  def days_since_signup
    (Date.current - created_at.to_date).to_i
  end

  def completed_profile?
    first_name.present? &&
    last_name.present? &&
    profile_picture.attached?
  end

  # Permission system
  def can_manage?(resource)
    return true if super_admin?

    case resource
    when Order
      # Users can manage their own orders
      return true if resource.user_id == id
      # Sellers can manage orders for their products
      return true if seller? && resource.product&.seller&.user_id == id
      # Admins can manage all orders
      return true if admin?
    when Product
      # Sellers can manage their own products
      return true if seller? && resource.seller&.user_id == id
      # Admins can manage all products
      return true if admin?
    when Review
      # Users can manage their own reviews
      return true if resource.user_id == id
      # Admins can manage all reviews
      return true if admin?
    end
    false
  end

  # Password validation (uncomment if needed)
  # validate :password_complexity
  #
  # def password_complexity
  #   return if password.blank? || password =~ /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/
  #
  #   errors.add :password, 'must include at least one lowercase letter, one uppercase letter, one digit, and one special character'
  # end

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

  def create_cart
    Cart.create(user: self) if cart.nil?
  rescue StandardError => e
    Rails.logger.error("Failed to create cart for user #{id}: #{e.message}")
    # Don't raise the error to prevent user creation failure
  end

  def set_default_preferences
    self.preferences ||= {}
    self.theme ||= "light"
    self.email_notifications ||= true
    self.marketing_emails ||= false
    self.two_factor_enabled ||= false
    self.currency_preference ||= "USD"
    self.language_preference ||= "en"
  end
end
