# frozen_string_literal: true

class Account::PaymentMethodsController < Account::BaseController
  before_action :set_payment_method, only: [:destroy, :set_default]

  def index
    @payment_methods = current_user.payment_methods.active.default_first
    @default_payment_method = @payment_methods.find_by(is_default: true)
  end

  def create
    @payment_method = build_payment_method_from_params

    if @payment_method.persisted?
      redirect_to account_payment_methods_path, notice: "Payment method added successfully."
    else
      @payment_methods = current_user.payment_methods.active.default_first
      flash.now[:alert] = @payment_method.errors.full_messages.to_sentence.presence || "Failed to add payment method."
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    if @payment_method.update(active: false)
      # If deleted card was default, make another one default
      if @payment_method.is_default? && current_user.payment_methods.active.any?
        current_user.payment_methods.active.first.update(is_default: true)
      end
      redirect_to account_payment_methods_path, notice: "Payment method removed successfully."
    else
      redirect_to account_payment_methods_path, alert: "Failed to remove payment method."
    end
  end

  def set_default
    if @payment_method.update(is_default: true)
      redirect_to account_payment_methods_path, notice: "Default payment method updated."
    else
      redirect_to account_payment_methods_path, alert: "Failed to update default payment method."
    end
  end

  private

  def set_payment_method
    @payment_method = current_user.payment_methods.find_by(id: params[:id])
    unless @payment_method
      redirect_to account_payment_methods_path, alert: "Payment method not found."
    end
  end

  def payment_method_params
    params.require(:payment_method).permit(
      :card_number, :cardholder_name, :expiry_date, :cvv, :nickname, :set_default
    )
  end

  def build_payment_method_from_params
    card_params = payment_method_params
    
    # Parse expiry date (MM/YY format)
    expiry_parts = card_params[:expiry_date].to_s.split('/')
    expiry_month = expiry_parts[0].to_i
    expiry_year = expiry_parts[1].to_i

    # Create the payment method
    payment_method = PaymentMethod.create_from_card(
      user: current_user,
      card_number: card_params[:card_number].to_s.gsub(/\s/, ''),
      cardholder_name: card_params[:cardholder_name],
      expiry_month: expiry_month,
      expiry_year: expiry_year,
      processor: 'stripe',
      nickname: card_params[:nickname].presence
    )

    # Set as default if requested
    if card_params[:set_default] == '1' && payment_method.persisted?
      payment_method.update(is_default: true)
    end

    payment_method
  end
end
