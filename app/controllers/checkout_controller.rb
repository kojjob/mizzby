class CheckoutController < ApplicationController
  before_action :authenticate_user!, except: [:buy_now]
  before_action :ensure_cart_not_empty, only: [:index, :create]
  before_action :set_cart, only: [:index, :create]

  def index
    @cart_items = @cart.cart_items.includes(:product)
    calculate_totals
  end

  def create
    @cart_items = @cart.cart_items.includes(:product)

    if @cart_items.empty?
      redirect_to products_path, alert: "Your cart is empty."
      return
    end

    # Validate payment details if credit card
    if params[:payment_method] == 'credit_card' && params[:card_details].present?
      validation = PaymentService.validate_card_details(card_params)
      unless validation[:valid]
        redirect_to checkout_path, alert: validation[:errors].join(', ')
        return
      end
    end

    calculate_totals
    orders_created = []
    errors = []

    ActiveRecord::Base.transaction do
      @cart_items.each do |item|
        order = build_order_from_cart_item(item)

        if order.save
          create_order_item(order, item)
          
          # Process payment
          payment_result = process_payment_for_order(order)
          
          if payment_result[:success]
            orders_created << order
          else
            errors << "Payment failed for #{item.product.name}: #{payment_result[:error]}"
            raise ActiveRecord::Rollback
          end
        else
          errors << "Order creation failed: #{order.errors.full_messages.join(', ')}"
          raise ActiveRecord::Rollback
        end
      end

      # Clear the cart after successful order creation
      @cart.cart_items.destroy_all if errors.empty?
    end

    if errors.empty? && orders_created.any?
      # Redirect to confirmation page
      if orders_created.size == 1
        redirect_to checkout_confirmation_path(order_id: orders_created.first.id)
      else
        redirect_to checkout_confirmation_path(order_ids: orders_created.map(&:id).join(','))
      end
    else
      redirect_to checkout_path, alert: errors.first || "Failed to process your order. Please try again."
    end
  end

  def confirmation
    if params[:order_id].present?
      @orders = [Order.find(params[:order_id])]
    elsif params[:order_ids].present?
      order_ids = params[:order_ids].split(',')
      @orders = Order.where(id: order_ids, user: current_user)
    else
      redirect_to account_orders_path and return
    end

    @order = @orders.first
    @total = @orders.sum(&:total_amount)
  end

  def processing
    # This view shows a payment processing animation
    # In a real implementation, this would be handled via JavaScript/AJAX
    @total = session[:checkout_total] || 0
  end

  def failed
    @error_message = params[:error] || session[:payment_error] || "Your payment could not be processed."
    @error_code = params[:code] || session[:payment_error_code]
    
    # Clear session payment error
    session.delete(:payment_error)
    session.delete(:payment_error_code)
  end

  def buy_now
    product_id = params[:product_id]
    quantity = (params[:quantity] || 1).to_i

    product = Product.find(product_id)

    if !product || (product.stock_quantity && product.stock_quantity < quantity && !product.is_digital?)
      redirect_to product_path(product), alert: "Sorry, this product is out of stock or doesn't have enough inventory."
      return
    end

    if user_signed_in?
      cart = current_user.cart || current_user.create_cart
      cart.cart_items.destroy_all if params[:direct_checkout]
    else
      session[:cart_id] = nil
      cart = create_guest_cart
    end

    price = product.discounted_price.presence || product.price
    cart_item = cart.cart_items.build(
      product_id: product_id, 
      quantity: quantity, 
      price: price
    )

    if cart_item.save
      redirect_to checkout_path, notice: "Proceeding to checkout for #{product.name}"
    else
      redirect_to product_path(product), alert: "Could not process your request: #{cart_item.errors.full_messages.join(', ')}"
    end
  end

  private

  def set_cart
    @cart = current_user.cart || current_user.create_cart
  end

  def ensure_cart_not_empty
    if user_signed_in? && (current_user.cart.nil? || current_user.cart.cart_items.empty?)
      redirect_to root_path, alert: "Your cart is empty. Please add items before proceeding to checkout."
    end
  end

  def create_guest_cart
    cart = Cart.create
    session[:cart_id] = cart.id
    cart
  end

  def calculate_totals
    @subtotal = @cart_items.sum { |item| 
      (item.product.discounted_price || item.product.price) * (item.quantity || 1) 
    }
    @tax = @subtotal * 0.05
    @shipping = calculate_shipping
    @total = @subtotal + @tax + @shipping
  end

  def calculate_shipping
    # Free shipping for digital products only orders
    has_physical = @cart_items.any? { |item| !item.product.is_digital? }
    has_physical ? 5.00 : 0
  end

  def build_order_from_cart_item(item)
    unit_price = item.product.discounted_price || item.product.price
    item_total = unit_price * (item.quantity || 1)
    
    Order.new(
      user: current_user,
      product: item.product,
      total_amount: item_total + (item_total * 0.05), # Including tax
      payment_processor: params[:payment_method] || 'credit_card',
      payment_method: params[:payment_method] || 'credit_card',
      payment_id: "PAY-#{SecureRandom.hex(8).upcase}",
      payment_status: 'pending',
      status: 'pending',
      shipping_cost: item.product.is_digital? ? 0 : 5.00,
      notes: params[:notes].presence || "Order placed via checkout"
    )
  end

  def create_order_item(order, cart_item)
    unit_price = cart_item.product.discounted_price || cart_item.product.price
    quantity = cart_item.quantity || 1

    order.order_items.create!(
      product: cart_item.product,
      quantity: quantity,
      unit_price: unit_price,
      total_price: unit_price * quantity,
      product_name: cart_item.product.name,
      product_sku: cart_item.product.sku || "SKU-#{cart_item.product.id}",
      product_description: cart_item.product.description&.truncate(500),
      shipping_address: cart_item.product.is_digital ? "Digital Delivery" : format_shipping_address,
      shipping_method: cart_item.product.is_digital ? "digital" : "standard",
      shipping_cost: cart_item.product.is_digital ? 0 : 5.00,
      payment_method: params[:payment_method] || "credit_card",
      payment_status: "pending",
      tax_rate: 5.0,
      tax_amount: unit_price * quantity * 0.05
    )
  end

  def format_shipping_address
    address = current_user.addresses.first
    address&.full_address || "Pending"
  end

  def process_payment_for_order(order)
    payment_service = PaymentService.new(
      order: order,
      payment_method: params[:payment_method] || 'credit_card',
      payment_details: {
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        card_last4: card_params[:card_number]&.last(4),
        phone_number: params[:phone_number]
      },
      user: current_user
    )

    payment_service.process_payment
  end

  def card_params
    return {} unless params[:card_details].present?
    
    params.require(:card_details).permit(
      :card_number, :exp_month, :exp_year, :cvv, :cardholder_name
    )
  end
end
