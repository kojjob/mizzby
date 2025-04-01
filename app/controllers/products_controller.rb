class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
    @products = Product.all
  end

  def search
    @query = params[:q]
    @products = Product.where("name ILIKE ? OR description ILIKE ?", "%#{@query}%", "%#{@query}%")
    # Add more search logic as needed
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, status: :see_other, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.expect(product: [ :name, :description, :price, :discounted_price, :stock_quantity, :sku, :barcode, :weight, :dimensions, :condition, :brand, :featured, :currency, :country_of_origin, :available_in_ghana, :available_in_nigeria, :shipping_time, :category_id, :seller_id, :published, :published_at, :meta_title, :meta_description, :is_digital, :status ])
    end

  def deals
    @products = Product.where(on_sale: true).or(Product.where("discount_percentage > ?", 0))
    # Add any additional logic you need for the deals page
  end

def new_arrivals
  # Get products published in the last 30 days
  base_query = Product.where(published: true)
                      .where("published_at >= ?", 30.days.ago)
                      .order(published_at: :desc)

  # Simple pagination
  @page = (params[:page] || 1).to_i
  @per_page = 12
  @new_products = base_query.limit(@per_page).offset((@page - 1) * @per_page)

  # For pagination links
  @total_count = base_query.count
  @total_pages = (@total_count.to_f / @per_page).ceil

  # We don't need featured products since the model doesn't exist
  # @featured_products = []
end
end
