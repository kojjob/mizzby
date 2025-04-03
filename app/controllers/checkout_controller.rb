class CheckoutController < ApplicationController
  before_action :authenticate_user!, except: [:buy_now]
  before_action :ensure_cart_not_empty, only: [:index]
  
  def index
    @cart = current_user.cart || Cart.new
    @cart_items = @cart.cart_items.includes(:product)
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