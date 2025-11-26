class CartItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart
  before_action :set_cart_item, only: [ :show, :edit, :update, :destroy ]

  def index
    @cart_items = @cart.cart_items.includes(:product)
  end

  def new
    @cart_item = @cart.cart_items.build
  end

  def show
  end

  def edit
  end

  def create
    # Support different param structures
    if params[:cart_item].present?
      # Standard REST API params
      @cart_item = @cart.cart_items.build(cart_item_params)
      product_name = @cart_item.product&.name
    else
      # Custom add-to-cart params
      product_id = params[:product_id] || params[:id]
      @product = Product.find(product_id)
      @quantity = params[:quantity]&.to_i || 1

      # Check if item already exists in cart
      existing_item = @cart.cart_items.find_by(product: @product)

      if existing_item
        # Update quantity if item exists
        existing_item.update(quantity: existing_item.quantity + @quantity)
        @cart_item = existing_item
      else
        # Create new cart item
        @cart_item = @cart.cart_items.build(product: @product, quantity: @quantity)
      end
      product_name = @product.name
    end

    respond_to do |format|
      if @cart_item.save
        format.html { 
          flash[:notice] = "#{product_name} added to your cart."
          redirect_back fallback_location: products_path
        }
        format.turbo_stream {
          flash.now[:notice] = "#{product_name} added to your cart."
          render turbo_stream: [
            turbo_stream.replace("cart-slideover", partial: "shared/cart_slideover"),
            turbo_stream.replace("cart-count-badge", partial: "shared/cart_count_badge"),
            turbo_stream.replace("flash", partial: "shared/flash_msg"),
            turbo_stream.append("notifications", "<script>document.dispatchEvent(new CustomEvent('cart:open'))</script>".html_safe)
          ]
        }
        format.json { render json: { 
          success: true, 
          cart_count: @cart.cart_items.sum(:quantity),
          item_count: @cart.cart_items.count,
          total: @cart.grand_total,
          product_name: product_name
        }, status: :created }
        format.js # For AJAX requests
      else
        format.html { redirect_to products_path, alert: @cart_item.errors.full_messages.join(", ") }
        format.turbo_stream { 
          flash.now[:alert] = @cart_item.errors.full_messages.join(", ")
          render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash_msg")
        }
        format.json { render json: @cart_item.errors, status: :unprocessable_entity }
        format.js { render js: "alert('#{@cart_item.errors.full_messages.join(", ")}');" }
      end
    end
  end

  def update
    respond_to do |format|
      if @cart_item.update(cart_item_params)
        format.html { redirect_to cart_item_url(@cart_item), notice: "Cart item updated successfully." }
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace("cart-slideover", partial: "shared/cart_slideover"),
            turbo_stream.replace("cart-count-badge", partial: "shared/cart_count_badge")
          ]
        }
        format.json { render json: { 
          success: true,
          cart_count: @cart.cart_items.sum(:quantity),
          item_count: @cart.cart_items.count,
          total: @cart.grand_total,
          subtotal: @cart_item.subtotal
        } }
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
      format.html { redirect_to cart_items_url, notice: "#{@product_name} removed from your cart." }
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace("cart-slideover", partial: "shared/cart_slideover"),
          turbo_stream.replace("cart-count-badge", partial: "shared/cart_count_badge")
        ]
      }
      format.json { render json: { 
        success: true,
        cart_count: @cart.cart_items.sum(:quantity),
        item_count: @cart.cart_items.count,
        total: @cart.grand_total
      } }
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
    params.require(:cart_item).permit(:quantity, :product_id, :price, :cart_id)
  end
end
