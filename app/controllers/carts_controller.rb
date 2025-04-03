class CartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart, only: [:show, :destroy, :empty]
  
  def current
    # Handle both authenticated and guest users
    if user_signed_in?
      # For authenticated users, use their associated cart
      @cart = current_user.cart || Cart.create(user: current_user)
    else
      # For guest users, use a session-based cart
      session[:cart_id] ||= SecureRandom.uuid
      @cart = Cart.find_by(cart_id: session[:cart_id]) || Cart.create(cart_id: session[:cart_id])
    end
    
    # Load cart items with their associated products to avoid N+1 queries
    @cart_items = @cart.cart_items.includes(:product)
    
    # Render the cart view
    render :show
  end
  
  def show
    @cart_items = @cart.cart_items.includes(:product)
  end
  
  def empty
    @cart.empty!
    redirect_to cart_path, notice: "Your cart has been emptied."
  end
  
  def destroy
    @cart.destroy
    redirect_to root_path, notice: "Your cart has been deleted."
  end
  
  private
  
  def set_cart
    if user_signed_in?
      @cart = current_user.cart
    else
      @cart = Cart.find_by(cart_id: session[:cart_id])
    end
    
    redirect_to products_path, alert: "You don't have an active cart." unless @cart
  end
end