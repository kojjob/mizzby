module UserCallbacks
  extend ActiveSupport::Concern

  included do
    # Create a cart for new users
    after_create :create_cart

    # Set default preferences
    after_initialize :set_default_preferences, if: :new_record?
  end

  private

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
