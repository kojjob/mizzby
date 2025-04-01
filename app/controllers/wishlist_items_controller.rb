class WishlistItemsController < ApplicationController
  before_action :set_wishlist_item, only: %i[ show edit update destroy ]

  # GET /wishlist_items or /wishlist_items.json
  def index
    @wishlist_items = WishlistItem.all
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
    @wishlist_item = WishlistItem.new(wishlist_item_params)

    respond_to do |format|
      if @wishlist_item.save
        format.html { redirect_to @wishlist_item, notice: "Wishlist item was successfully created." }
        format.json { render :show, status: :created, location: @wishlist_item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @wishlist_item.errors, status: :unprocessable_entity }
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
      format.html { redirect_to wishlist_items_path, status: :see_other, notice: "Wishlist item was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wishlist_item
      @wishlist_item = WishlistItem.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def wishlist_item_params
      params.expect(wishlist_item: [ :user_id, :product_id, :notes ])
    end

    # Add this method to your existing WishlistItemsController
    def clear
      current_user.wishlist_items.destroy_all
      redirect_to wishlist_items_path, notice: "Your wishlist has been cleared."
    end
end
