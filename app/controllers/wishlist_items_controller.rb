class WishlistItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wishlist_item, only: %i[ show edit update destroy ]

  # GET /wishlist_items or /wishlist_items.json
  def index
    @wishlist_items = current_user.wishlist_items.includes(:product).order(created_at: :desc)
    
    respond_to do |format|
      format.html
      format.json { 
        render json: { 
          count: @wishlist_items.count,
          items: @wishlist_items.map { |item| 
            { 
              id: item.id, 
              product_id: item.product_id, 
              product_name: item.product.name,
              product_price: item.product.price.to_f,
              created_at: item.created_at 
            } 
          }
        }
      }
    end
  end

  # GET /wishlist_items/1 or /wishlist_items/1.json
  def show
  end

  # GET /wishlist_items/new
  def new
    @wishlist_item = WishlistItem.new
  end

  # GET /wishlist_items/1/edit
  def edit
  end

  # POST /wishlist_items or /wishlist_items.json
  def create
    # Handle product_id passed directly in params (from button_to)
    product_id = params.dig(:wishlist_item, :product_id) || params[:product_id]
    @wishlist_item = current_user.wishlist_items.build(product_id: product_id, notes: params.dig(:wishlist_item, :notes))

    respond_to do |format|
      if @wishlist_item.save
        format.html { redirect_back fallback_location: products_path, notice: "Added to wishlist!" }
        format.json { render json: { success: true, message: "Added to wishlist!", count: current_user.wishlist_items.count }, status: :created }
        format.turbo_stream { 
          flash.now[:notice] = "Added to wishlist!"
          render turbo_stream: [
            turbo_stream.replace("wishlist-count-badge", partial: "shared/wishlist_count_badge"),
            turbo_stream.replace("wishlist-slideover", partial: "shared/wishlist_slideover"),
            turbo_stream.replace("flash", partial: "shared/flash_msg")
          ]
        }
      else
        format.html { redirect_back fallback_location: products_path, alert: @wishlist_item.errors.full_messages.join(", ") }
        format.json { render json: { success: false, errors: @wishlist_item.errors.full_messages, message: @wishlist_item.errors.full_messages.first }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wishlist_items/1 or /wishlist_items/1.json
  def update
    respond_to do |format|
      if @wishlist_item.update(wishlist_item_params)
        format.html { redirect_to @wishlist_item, notice: "Wishlist item was successfully updated." }
        format.json { render :show, status: :ok, location: @wishlist_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @wishlist_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wishlist_items/1 or /wishlist_items/1.json
  def destroy
    @wishlist_item.destroy!

    respond_to do |format|
      format.html { redirect_to wishlist_items_path, status: :see_other, notice: "Item removed from wishlist." }
      format.json { render json: { success: true, message: "Item removed from wishlist.", count: current_user.wishlist_items.count } }
      format.turbo_stream {
        flash.now[:notice] = "Item removed from wishlist."
        render turbo_stream: [
          turbo_stream.replace("wishlist-count-badge", partial: "shared/wishlist_count_badge"),
          turbo_stream.replace("wishlist-slideover", partial: "shared/wishlist_slideover"),
          turbo_stream.replace("flash", partial: "shared/flash_msg")
        ]
      }
    end
  end

  # DELETE /wishlist_items/clear
  def clear
    current_user.wishlist_items.destroy_all
    
    respond_to do |format|
      format.html { redirect_to wishlist_items_path, notice: "Your wishlist has been cleared." }
      format.json { render json: { success: true, message: "Wishlist cleared.", count: 0 } }
    end
  end

  # DELETE /wishlist_items/remove_by_product?product_id=123
  def remove_by_product
    @wishlist_item = current_user.wishlist_items.find_by(product_id: params[:product_id])
    
    if @wishlist_item
      @wishlist_item.destroy!
      respond_to do |format|
        format.html { redirect_to wishlist_items_path, status: :see_other, notice: "Item removed from wishlist." }
        format.json { render json: { success: true, message: "Item removed from wishlist.", count: current_user.wishlist_items.count } }
      end
    else
      respond_to do |format|
        format.html { redirect_to wishlist_items_path, alert: "Item not found in wishlist." }
        format.json { render json: { success: false, message: "Item not found in wishlist." }, status: :not_found }
      end
    end
  end

  # POST /wishlist_items/:id/move_to_cart
  def move_to_cart
    @wishlist_item = current_user.wishlist_items.find(params[:id])
    success, message = @wishlist_item.move_to_cart
    
    respond_to do |format|
      if success
        format.html { redirect_back fallback_location: wishlist_items_path, notice: message }
        format.json { render json: { success: true, message: message, wishlist_count: current_user.wishlist_items.count, cart_count: current_user.cart&.cart_items&.sum(:quantity).to_i } }
      else
        format.html { redirect_back fallback_location: wishlist_items_path, alert: message }
        format.json { render json: { success: false, message: message }, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wishlist_item
      @wishlist_item = current_user.wishlist_items.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def wishlist_item_params
      params.expect(wishlist_item: [ :product_id, :notes ])
    end
end
