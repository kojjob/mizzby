class CartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart, only: [ :show, :edit, :update, :destroy, :empty ]

  def index
    @carts = Cart.where(user: current_user)
  end

  def new
    @cart = Cart.new
  end

  def create
    @cart = Cart.new(cart_params)
    @cart.user = current_user

    if @cart.save
      redirect_to @cart, notice: "Cart was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @cart.update(cart_params)
      redirect_to @cart, notice: "Cart was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

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

    respond_to do |format|
      format.html { render :show }
      format.json { 
        render json: {
          item_count: @cart.cart_items.sum(:quantity),
          items_count: @cart.cart_items.count,
          total: @cart.grand_total,
          subtotal: @cart.total_price,
          shipping: @cart.shipping_cost,
          items: @cart_items.map { |item| {
            id: item.id,
            product_id: item.product_id,
            product_name: item.product&.name,
            quantity: item.quantity,
            price: item.price,
            subtotal: item.subtotal
          }}
        }
      }
    end
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
    redirect_to carts_path, notice: "Your cart has been deleted."
  end

  private

  def set_cart
    if user_signed_in?
      @cart = current_user.cart || Cart.find(params[:id])
    else
      @cart = Cart.find_by(cart_id: session[:cart_id]) || Cart.find(params[:id])
    end

    redirect_to products_path, alert: "You don't have an active cart." unless @cart
  end

  def cart_params
    params.require(:cart).permit(:user_id)
  end
end
