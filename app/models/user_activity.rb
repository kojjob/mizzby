class UserActivity < ApplicationRecord
  belongs_to :user
  belongs_to :reference, polymorphic: true, optional: true

  # Validations
  validates :activity_type, :title, presence: true
  validates :icon, :color, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }

  # Activity types
  ACTIVITY_TYPES = [
    "login",
    "logout",
    "profile_updated",
    "password_changed",
    "order_placed",
    "order_paid",
    "order_completed",
    "order_cancelled",
    "product_viewed",
    "product_reviewed",
    "product_question_asked",
    "product_added_to_cart",
    "product_added_to_wishlist"
  ].freeze

  # Default values for icon and color based on activity type
  before_validation :set_defaults

  private

  def set_defaults
    self.icon ||= default_icon
    self.color ||= default_color
  end

  def default_icon
    case activity_type
    when "login", "logout" then "login"
    when "profile_updated", "password_changed" then "user"
    when "order_placed", "order_paid", "order_completed", "order_cancelled" then "shopping-bag"
    when "product_viewed", "product_reviewed" then "eye"
    when "product_question_asked" then "chat"
    when "product_added_to_cart" then "shopping-cart"
    when "product_added_to_wishlist" then "heart"
    else "activity"
    end
  end

  def default_color
    case activity_type
    when "login", "logout" then "green"
    when "profile_updated", "password_changed" then "blue"
    when "order_placed", "order_paid" then "indigo"
    when "order_completed" then "green"
    when "order_cancelled" then "red"
    when "product_viewed" then "gray"
    when "product_reviewed" then "yellow"
    when "product_question_asked" then "orange"
    when "product_added_to_cart" then "purple"
    when "product_added_to_wishlist" then "pink"
    else "blue"
    end
  end
end
