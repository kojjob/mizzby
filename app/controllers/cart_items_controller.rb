class CartItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart
  before_action :set_cart_item, only: [:update, :destroy]
  
  def create
    @product = Product.find(params[:product_id])
    @quantity = params[:quantity].to_i || 1
    
    # Check if item already exists in cart
    @cart_item = @cart.cart_items.find_by(product: @product)
    
    if @cart_item
      # Update quantity if item exists
      @cart_item.update(quantity: @cart_item.quantity + @quantity)
    else
      # Create new cart item
      @cart_item = @cart.cart_items.build(product: @product, quantity: @quantity)
    end
    
    respond_to do |format|
      if @cart_item.save
        format.html { redirect_to cart_path, notice: "#{@product.name} added to your cart." }
        format.json { render json: @cart_item, status: :created }
        format.js # For AJAX requests
      else
        format.html { redirect_to product_path(@product), alert: @cart_item.errors.full_messages.join(", ") }
        format.json { render json: @cart_item.errors, status: :unprocessable_entity }
        format.js { render js: "alert('#{@cart_item.errors.full_messages.join(", ")}');" }
      end
    end
  end
  
  def update
    respond_to do |format|
      if @cart_item.update(cart_item_params)
        format.html { redirect_to cart_path, notice: "Cart updated successfully." }
        format.json { render json: @cart_item }
        format.js # For AJAX requests
      else
        format.html { redirect_to cart_path, alert: @cart_item.errors.full_messages.join(", ") }
        format.json { render json: @cart_item.errors, status: :unprocessable_entity }
        format.js { render js: "alert('#{@cart_item.errors.full_messages.join(", ")}');" }
      end
    end
  end
  
  def destroy
    @product_name = @cart_item.product.name
    @cart_item.destroy
    
    respond_to do |format|
      format.html { redirect_to cart_path, notice: "#{@product_name} removed from your cart." }
      format.json { head :no_content }
      format.js # For AJAX requests
    end
  end
  
  private
  
  def set_cart
    @cart = current_user.cart
    
    # Create cart if it doesn't exist
    if @cart.nil?
      @cart = current_user.create_cart
    end
  end
  
  def set_cart_item
    @cart_item = @cart.cart_items.find(params[:id])
  end
  
  def cart_item_params
    params.require(:cart_item).permit(:quantity)
  end
end