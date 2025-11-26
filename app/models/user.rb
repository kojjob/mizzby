class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable, :lockable,
         :recoverable, :rememberable, :validatable, :timeoutable, :trackable

  # Include concerns
  include UserAssociations
  include UserValidations
  include UserCallbacks
  include UserScopes

  # --- Enums ---
  # User roles (if you have a role column)
  # enum :role, { customer: 0, seller: 1, admin: 2, super_admin: 3 }, default: :customer

  # Account status
  # enum :status, { inactive: 0, active: 1, suspended: 2 }, default: :active

  # User preferences
  store_accessor :preferences, :theme, :email_notifications, :marketing_emails,
                :two_factor_enabled, :currency_preference, :language_preference

  # --- Delegations ---
  # Check if user is a seller
  delegate :present?, to: :seller, prefix: true, allow_nil: true

  # --- Methods ---
  # Role checking methods - explicit definitions override Rails' auto-generated methods
  def admin?
    # Super admins are also admins
    read_attribute(:admin) || super_admin?
  end

  def super_admin?
    # Explicit check of the super_admin column
    read_attribute(:super_admin) == true
  end

  def has_role?(role_name)
    case role_name.to_s
    when "super_admin" then super_admin?
    when "admin" then admin?
    when "seller" then defined?(seller) && seller.present?
    when "customer" then !super_admin? && !admin? && !(defined?(seller) && seller.present?)
    else false
    end
  end

  # Helpful role predicates for cleaner code
  def customer?
    !admin? && !super_admin? && !(defined?(seller) && seller.present?)
  end

  def seller?
    defined?(seller) && seller.present?
  end

  # Status methods
  def active_for_authentication?
    super && active?
  end

  # Return a custom message instead of a translation key
  def inactive_message
    active? ? super : "Your account is currently inactive. Please contact support for assistance."
  end

  # Check if user is active
  def active?
    # If there's no active column, assume the user is active unless they're locked
    return !access_locked? unless respond_to?(:status)

    # If there is a status column, check if it's set to active
    status == "active"
  end

  # User name and display methods
  def full_name
    # Use sanitized values to prevent XSS
    sanitized_first = ActionController::Base.helpers.sanitize(first_name) if first_name.present?
    sanitized_last = ActionController::Base.helpers.sanitize(last_name) if last_name.present?

    [ sanitized_first, sanitized_last ].compact.join(" ").presence ||
      ActionController::Base.helpers.sanitize(email.split("@").first)
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
    profile_picture_attached?
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

  # Helper method to get active cart or create one
  def current_cart
    cart || create_cart
  end

  # Method to convert cart to order
  def checkout_cart
    return nil unless cart&.cart_items&.any?

    # Start a transaction to ensure data integrity
    transaction do
      # Create orders for each product (or group them as needed)
      orders = []

      cart.cart_items.each do |item|
        order = orders.build(
          product: item.product,
          total_amount: item.subtotal,
          status: "pending",
          payment_status: "pending"
        )

        # Handle digital product delivery if payment is successful
        if item.product.is_digital
          # Create download link after payment processing
          # This would happen in a callback or service
        end
      end

      # Mark cart as converted
      cart.update(status: :converted)

      return orders
    end
  end
end
