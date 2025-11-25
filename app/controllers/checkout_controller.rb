class CheckoutController < ApplicationController
  before_action :authenticate_user!, except: [ :buy_now ]
  before_action :ensure_cart_not_empty, only: [ :index, :create ]

  def index
    @cart = current_user.cart || Cart.new
    @cart_items = @cart.cart_items.includes(:product)
  end

  def create
    @cart = current_user.cart
    @cart_items = @cart.cart_items.includes(:product)

    if @cart_items.empty?
      redirect_to products_path, alert: "Your cart is empty."
      return
    end

    # Calculate totals
    subtotal = @cart_items.sum { |item| (item.product.discounted_price || item.product.price) * (item.quantity || 1) }
    tax = subtotal * 0.05
    total = subtotal + tax

    # Create orders for each cart item (grouped by seller if needed)
    orders_created = []
    errors = []

    ActiveRecord::Base.transaction do
      @cart_items.each do |item|
        order = Order.new(
          user: current_user,
          product: item.product,
          total_amount: (item.product.discounted_price || item.product.price) * (item.quantity || 1),
          payment_processor: params[:payment_method] || "credit_card",
          payment_id: "PAY-#{SecureRandom.hex(8).upcase}",
          payment_status: "pending",
          status: "pending",
          notes: "Order placed via checkout"
        )

        if order.save
          # Create order item with all required fields
          unit_price = item.product.discounted_price || item.product.price
          order.order_items.create!(
            product: item.product,
            quantity: item.quantity || 1,
            unit_price: unit_price,
            total_price: unit_price * (item.quantity || 1),
            product_name: item.product.name,
            product_sku: item.product.sku || "SKU-#{item.product.id}",
            product_description: item.product.description&.truncate(500),
            shipping_address: item.product.is_digital ? "Digital Delivery" : (current_user.addresses.first&.full_address || "Pending"),
            shipping_method: item.product.is_digital ? "digital" : "standard",
            shipping_cost: item.product.is_digital ? 0 : 5.00,
            payment_method: params[:payment_method] || "credit_card",
            payment_status: "pending",
            tax_rate: 5.0,
            tax_amount: unit_price * (item.quantity || 1) * 0.05
          )
          orders_created << order
        else
          errors << order.errors.full_messages.join(", ")
        end
      end

      if errors.any?
        raise ActiveRecord::Rollback
      end

      # Clear the cart after successful order creation
      @cart.cart_items.destroy_all
    end

    if errors.empty? && orders_created.any?
      # Redirect to order confirmation
      if orders_created.size == 1
        redirect_to order_path(orders_created.first), notice: "Order placed successfully! Thank you for your purchase."
      else
        redirect_to account_orders_path, notice: "#{orders_created.size} orders placed successfully! Thank you for your purchase."
      end
    else
      redirect_to checkout_path, alert: "Failed to process your order: #{errors.join(', ')}"
    end
  end

  def buy_now
    product_id = params[:product_id]
    quantity = params[:quantity] || 1

    # Find the product
    product = Product.find(product_id)

    if !product || (product.stock_quantity && product.stock_quantity < quantity.to_i && !product.is_digital?)
      redirect_to product_path(product), alert: "Sorry, this product is out of stock or doesn't have enough inventory."
      return
    end

    # Create a temporary cart or get current user's cart
    if user_signed_in?
      cart = current_user.cart || current_user.create_cart

      # Clear existing items if it's a direct buy
      cart.cart_items.destroy_all if params[:direct_checkout]
    else
      # For guest users, use a session-based cart
      session[:cart_id] = nil # Force a new cart for buy now
      cart = create_guest_cart
    end

    # Add the product to the cart
    price = product.discounted_price.present? ? product.discounted_price : product.price
    cart_item = cart.cart_items.build(product_id: product_id, quantity: quantity, price: price)

    if cart_item.save
      redirect_to checkout_path, notice: "Proceeding to checkout for #{product.name}"
    else
      redirect_to product_path(product), alert: "Could not process your request: #{cart_item.errors.full_messages.join(', ')}"
    end
  end

  private

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
end
