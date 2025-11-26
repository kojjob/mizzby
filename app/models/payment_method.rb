# frozen_string_literal: true

# PaymentMethod model for storing saved payment methods
# Stores tokenized card information - NEVER stores actual card numbers
class PaymentMethod < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :card_type, presence: true, inclusion: { in: %w[visa mastercard amex discover diners jcb] }
  validates :last_four, presence: true, length: { is: 4 }, format: { with: /\A\d{4}\z/ }
  validates :cardholder_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :expiry_month, presence: true, inclusion: { in: 1..12 }
  validates :expiry_year, presence: true
  validates :payment_processor, presence: true
  validate :expiry_date_not_in_past

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_default, -> { order(is_default: :desc, created_at: :desc) }
  scope :default_first, -> { order(is_default: :desc, created_at: :desc) }

  # Callbacks
  before_save :ensure_single_default
  after_save :update_user_default_payment, if: :is_default?

  # Card type icons mapping
  CARD_ICONS = {
    'visa' => { color: 'bg-blue-600', label: 'VISA' },
    'mastercard' => { color: 'bg-red-500', label: 'MC' },
    'amex' => { color: 'bg-blue-400', label: 'AMEX' },
    'discover' => { color: 'bg-orange-500', label: 'DISC' },
    'diners' => { color: 'bg-gray-600', label: 'DC' },
    'jcb' => { color: 'bg-green-600', label: 'JCB' }
  }.freeze

  # Display methods
  def display_name
    nickname.presence || "#{card_type.titleize} •••• #{last_four}"
  end

  def masked_number
    "•••• •••• •••• #{last_four}"
  end

  def expiry_display
    "#{format('%02d', expiry_month)}/#{expiry_year.to_s[-2..]}"
  end

  def expired?
    return true if expiry_year < Date.current.year
    return true if expiry_year == Date.current.year && expiry_month < Date.current.month

    false
  end

  def expires_soon?
    return false if expired?

    expiry_date = Date.new(expiry_year, expiry_month, 1).end_of_month
    expiry_date <= 3.months.from_now
  end

  def card_icon_info
    CARD_ICONS[card_type] || { color: 'bg-gray-500', label: card_type.upcase[0..3] }
  end

  # Class methods for creating from card details
  class << self
    def create_from_card(user:, card_number:, cardholder_name:, expiry_month:, expiry_year:, processor: 'stripe', nickname: nil)
      # In production, this would tokenize with the payment processor
      # For now, we simulate tokenization
      card_type = detect_card_type(card_number)
      last_four = card_number.gsub(/\s/, '')[-4..]
      token = generate_token(user.id, last_four)

      create(
        user: user,
        card_type: card_type,
        last_four: last_four,
        cardholder_name: cardholder_name,
        expiry_month: expiry_month.to_i,
        expiry_year: normalize_expiry_year(expiry_year),
        payment_processor: processor,
        token: token,
        nickname: nickname,
        is_default: user.payment_methods.active.none?
      )
    end

    def detect_card_type(number)
      clean_number = number.gsub(/\s/, '')

      case clean_number
      when /^4/ then 'visa'
      when /^5[1-5]/, /^2[2-7]/ then 'mastercard'
      when /^3[47]/ then 'amex'
      when /^6(?:011|5)/ then 'discover'
      when /^3(?:0[0-5]|[68])/ then 'diners'
      when /^35/ then 'jcb'
      else 'visa' # Default
      end
    end

    private

    def generate_token(user_id, last_four)
      "pm_#{SecureRandom.hex(16)}_#{user_id}_#{last_four}"
    end

    def normalize_expiry_year(year)
      year_int = year.to_i
      # Handle 2-digit years
      return year_int + 2000 if year_int < 100

      year_int
    end
  end

  private

  def expiry_date_not_in_past
    return if expiry_month.blank? || expiry_year.blank?
    return unless expired?

    errors.add(:base, 'Card has expired')
  end

  def ensure_single_default
    return unless is_default? && is_default_changed?

    user.payment_methods.where.not(id: id).update_all(is_default: false)
  end

  def update_user_default_payment
    # Update user preferences with default payment method if needed
    user.update(preferences: user.preferences.merge('default_payment_method_id' => id))
  end
end
