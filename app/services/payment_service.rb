# frozen_string_literal: true

class PaymentService
  class PaymentError < StandardError; end
  class InvalidPaymentMethodError < PaymentError; end
  class PaymentDeclinedError < PaymentError; end
  class PaymentProcessingError < PaymentError; end

  SUPPORTED_PROCESSORS = %w[credit_card paypal mobile_money stripe].freeze
  SUPPORTED_CARD_TYPES = %w[visa mastercard amex discover].freeze

  attr_reader :order, :payment_method, :payment_details, :user

  def initialize(order:, payment_method:, payment_details: {}, user: nil)
    @order = order
    @payment_method = payment_method
    @payment_details = payment_details
    @user = user || order.user
  end

  # Process the payment for the given order
  def process_payment
    validate_payment_method!
    
    result = case payment_method
    when 'credit_card'
      process_credit_card_payment
    when 'paypal'
      process_paypal_payment
    when 'mobile_money'
      process_mobile_money_payment
    when 'stripe'
      process_stripe_payment
    else
      raise InvalidPaymentMethodError, "Unsupported payment method: #{payment_method}"
    end

    if result[:success]
      finalize_successful_payment(result)
    else
      handle_failed_payment(result)
    end

    result
  rescue StandardError => e
    handle_payment_error(e)
  end

  # Refund a processed payment
  def refund_payment(reason: nil)
    unless order.payment_status == 'paid'
      return { success: false, error: 'Order has not been paid' }
    end

    result = case order.payment_processor
    when 'credit_card', 'stripe'
      process_credit_card_refund
    when 'paypal'
      process_paypal_refund
    when 'mobile_money'
      process_mobile_money_refund
    else
      { success: true, refund_id: generate_refund_id }
    end

    if result[:success]
      finalize_refund(result, reason)
    end

    result
  end

  # Validate payment details
  def self.validate_card_details(card_params)
    errors = []
    
    # Card number validation (Luhn algorithm)
    unless valid_card_number?(card_params[:card_number])
      errors << 'Invalid card number'
    end

    # Expiry date validation
    unless valid_expiry_date?(card_params[:exp_month], card_params[:exp_year])
      errors << 'Card has expired or invalid expiry date'
    end

    # CVV validation
    unless valid_cvv?(card_params[:cvv])
      errors << 'Invalid CVV'
    end

    # Cardholder name
    if card_params[:cardholder_name].blank?
      errors << 'Cardholder name is required'
    end

    { valid: errors.empty?, errors: errors }
  end

  # Detect card type from number
  def self.detect_card_type(card_number)
    return nil if card_number.blank?
    
    cleaned = card_number.to_s.gsub(/\D/, '')
    
    case cleaned
    when /^4/ then 'visa'
    when /^5[1-5]/, /^2[2-7]/ then 'mastercard'
    when /^3[47]/ then 'amex'
    when /^6(?:011|5)/ then 'discover'
    else 'unknown'
    end
  end

  private

  def validate_payment_method!
    unless SUPPORTED_PROCESSORS.include?(payment_method)
      raise InvalidPaymentMethodError, "Payment method '#{payment_method}' is not supported"
    end
  end

  # Credit Card Processing
  def process_credit_card_payment
    # In production, this would integrate with Stripe, Braintree, etc.
    # For now, simulate payment processing
    
    transaction_id = generate_transaction_id('CC')
    
    # Simulate processing delay
    # sleep(0.5)
    
    # Simulate 95% success rate
    if simulate_payment_success?(0.95)
      {
        success: true,
        transaction_id: transaction_id,
        processor: 'credit_card',
        processor_response: {
          authorization_code: SecureRandom.hex(4).upcase,
          avs_result: 'M',
          cvv_result: 'M'
        }
      }
    else
      {
        success: false,
        error: 'Payment declined',
        error_code: 'card_declined',
        processor_response: { decline_code: 'insufficient_funds' }
      }
    end
  end

  # PayPal Processing
  def process_paypal_payment
    transaction_id = generate_transaction_id('PP')
    
    if simulate_payment_success?(0.95)
      {
        success: true,
        transaction_id: transaction_id,
        processor: 'paypal',
        processor_response: {
          payer_email: payment_details[:payer_email] || user.email,
          payer_id: SecureRandom.hex(8).upcase
        }
      }
    else
      {
        success: false,
        error: 'PayPal payment failed',
        error_code: 'paypal_error'
      }
    end
  end

  # Mobile Money Processing (for African markets)
  def process_mobile_money_payment
    transaction_id = generate_transaction_id('MM')
    
    if simulate_payment_success?(0.90)
      {
        success: true,
        transaction_id: transaction_id,
        processor: 'mobile_money',
        processor_response: {
          phone_number: payment_details[:phone_number],
          network: payment_details[:network] || 'mtn',
          reference: SecureRandom.hex(6).upcase
        }
      }
    else
      {
        success: false,
        error: 'Mobile money payment failed',
        error_code: 'mm_error'
      }
    end
  end

  # Stripe Processing
  def process_stripe_payment
    transaction_id = generate_transaction_id('STR')
    
    if simulate_payment_success?(0.95)
      {
        success: true,
        transaction_id: transaction_id,
        processor: 'stripe',
        processor_response: {
          charge_id: "ch_#{SecureRandom.hex(12)}",
          receipt_url: "https://pay.stripe.com/receipts/#{SecureRandom.hex(8)}"
        }
      }
    else
      {
        success: false,
        error: 'Stripe payment failed',
        error_code: 'stripe_error'
      }
    end
  end

  # Refund Processing
  def process_credit_card_refund
    { success: true, refund_id: generate_refund_id }
  end

  def process_paypal_refund
    { success: true, refund_id: generate_refund_id }
  end

  def process_mobile_money_refund
    { success: true, refund_id: generate_refund_id }
  end

  # Finalization Methods
  def finalize_successful_payment(result)
    order.update!(
      payment_status: 'paid',
      status: order.product&.is_digital? ? 'completed' : 'processing',
      transaction_id: result[:transaction_id],
      payment_processor: result[:processor],
      payment_details: result[:processor_response].to_json
    )

    # Create audit log
    create_payment_audit_log('payment_success', result)

    # Generate download links for digital products
    if order.product&.is_digital?
      generate_download_links
    end

    # Send confirmation email
    OrderMailer.confirmation([order.id], order.user_id).deliver_later if defined?(OrderMailer)
  end

  def handle_failed_payment(result)
    order.update!(
      payment_status: 'failed',
      payment_details: result.to_json
    )

    create_payment_audit_log('payment_failed', result)
  end

  def handle_payment_error(error)
    Rails.logger.error("Payment error for order #{order.id}: #{error.message}")
    
    order.update!(
      payment_status: 'failed',
      payment_details: { error: error.message, error_class: error.class.name }.to_json
    )

    create_payment_audit_log('payment_error', { error: error.message })

    {
      success: false,
      error: error.message,
      error_code: 'processing_error'
    }
  end

  def finalize_refund(result, reason)
    order.update!(
      payment_status: 'refunded',
      status: 'refunded'
    )

    # Deactivate download links
    order.download_links.update_all(active: false) if order.product&.is_digital?

    create_payment_audit_log('refund_processed', { 
      refund_id: result[:refund_id], 
      reason: reason 
    })

    # Send refund confirmation email
    OrderMailer.refund_confirmation(order).deliver_later if defined?(OrderMailer)
  end

  def generate_download_links
    return unless order.product&.is_digital?
    return if order.download_links.any?

    DownloadLink.create!(
      product: order.product,
      user: order.user,
      order: order,
      token: SecureRandom.hex(16),
      expires_at: 30.days.from_now,
      download_count: 0,
      download_limit: 5,
      active: true
    )
  end

  def create_payment_audit_log(event_type, metadata)
    PaymentAuditLog.create!(
      user: user,
      order: order,
      event_type: event_type,
      payment_processor: payment_method,
      amount: order.total_amount,
      transaction_id: metadata[:transaction_id],
      metadata: metadata.to_json,
      ip_address: payment_details[:ip_address],
      user_agent: payment_details[:user_agent]
    )
  rescue StandardError => e
    Rails.logger.error("Failed to create payment audit log: #{e.message}")
  end

  # Helper Methods
  def generate_transaction_id(prefix)
    "#{prefix}-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(8).upcase}"
  end

  def generate_refund_id
    "REF-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(6).upcase}"
  end

  def simulate_payment_success?(success_rate)
    rand <= success_rate
  end

  # Class Methods for Validation
  class << self
    def valid_card_number?(number)
      return false if number.blank?
      
      digits = number.to_s.gsub(/\D/, '')
      return false unless digits.length.between?(13, 19)
      
      # Luhn algorithm
      sum = 0
      digits.reverse.chars.each_with_index do |digit, index|
        n = digit.to_i
        n *= 2 if index.odd?
        n -= 9 if n > 9
        sum += n
      end
      
      (sum % 10).zero?
    end

    def valid_expiry_date?(month, year)
      return false if month.blank? || year.blank?
      
      exp_month = month.to_i
      exp_year = year.to_i
      exp_year += 2000 if exp_year < 100
      
      return false unless exp_month.between?(1, 12)
      
      expiry_date = Date.new(exp_year, exp_month, -1)
      expiry_date >= Date.current
    end

    def valid_cvv?(cvv)
      return false if cvv.blank?
      cvv.to_s.gsub(/\D/, '').length.between?(3, 4)
    end

    def mask_card_number(number)
      return '' if number.blank?
      digits = number.to_s.gsub(/\D/, '')
      "****-****-****-#{digits.last(4)}"
    end
  end
end
