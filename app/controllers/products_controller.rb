class ProductsController < ApplicationController
  include PaginationHelper
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
    # Base query with comprehensive includes to avoid N+1 queries
    base_query = Product.where(published: true)
                       .includes(:category, :seller)

    # Filter by category if requested
    if params[:category_id].present?
      base_query = base_query.where(category_id: params[:category_id])
    end

    # Apply sorting
    case params[:sort]
    when 'price-low'
      base_query = base_query.order(price: :asc)
    when 'price-high'
      base_query = base_query.order(price: :desc)
    when 'popular'
      # Assuming you have a way to track popularity - adjust as needed
      base_query = base_query.order(created_at: :desc) # Fallback to newest
    else # default to newest
      base_query = base_query.order(created_at: :desc)
    end

    # Use Kaminari for pagination with fallback
    @products = paginate_safely(base_query, params[:page], 12)

    # Special product collections - with comprehensive includes to avoid N+1 queries
    @on_sale_products = Product.where("discounted_price IS NOT NULL AND discounted_price < price")
                              .where(published: true)
                              .includes(:category, :seller)
                              .order(created_at: :desc)
                              .limit(4)

    # You can add more filtering options as needed
    @flash_sales = @on_sale_products.where("discounted_price <= price * 0.5").limit(4)
    @clearance = @on_sale_products.where("stock_quantity < 10").limit(4)
  end

  # app/controllers/products_controller.rb
  def search
    @query = params[:query]

    # Initialize with empty array if no query
    @products = []

    if @query.present?
      # Base search query
      @products = Product.where(published: true)
                        .where("name ILIKE ? OR description ILIKE ?", "%#{@query}%", "%#{@query}%")

      # Apply category filter
      if params[:category_id].present?
        @products = @products.where(category_id: params[:category_id])
      end

      # Apply price filters
      if params[:min_price].present? && params[:max_price].present?
        min_price = params[:min_price].to_f
        max_price = params[:max_price].to_f
        @products = @products.where(price: min_price..max_price)
      end

      # Apply product type filters
      @products = @products.where(is_digital: true) if params[:digital] == "1"
      @products = @products.where(on_sale: true) if params[:on_sale] == "1"

      # Apply sorting
      case params[:sort]
      when "price_asc"
        @products = @products.order(price: :asc)
      when "price_desc"
        @products = @products.order(price: :desc)
      when "newest"
        @products = @products.order(created_at: :desc)
      else
        # Default sort by relevance (keep as is)
      end
    end
  end

  # GET /products/1 or /products/1.json
  def show
    # Find related products in the same category
    @related_products = Product.where(category_id: @product.category_id)
                               .where.not(id: @product.id)
                               .where(published: true)
                               .includes(:category, :seller, :product_images)
                               .limit(4)
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
    # Get the product parameters
    attributes = product_params.to_h

    # Handle the featured attribute specifically
    if params[:product][:featured] == '0'
      attributes[:featured] = false
    elsif params[:product][:featured] == '1'
      attributes[:featured] = true
    end

    # Handle the status attribute specifically
    if params[:product][:status] == 'draft'
      attributes[:status] = 'inactive'
    end

    @product = Product.new(attributes)

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
      # Get the product parameters
      attributes = product_params.to_h

      # Handle the featured attribute specifically
      if params[:product][:featured] == '0'
        attributes[:featured] = false
      elsif params[:product][:featured] == '1'
        attributes[:featured] = true
      end

      # Handle the status attribute specifically
      if params[:product][:status] == 'draft'
        attributes[:status] = 'inactive'
      end

      if @product.update(attributes)
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
      # Find the product with eager loading to prevent N+1 queries
      @product = Product.includes(:category, :seller, :product_images, :reviews, :product_questions).find(params.require(:id))

      # For edit/update/destroy actions, verify the current user has permission
      if ['edit', 'update', 'destroy'].include?(action_name) && !can_modify_product?(@product)
        flash[:alert] = "You don't have permission to modify this product."
        redirect_to products_path and return
      end
    end

    # Check if the current user can modify the product
    def can_modify_product?(product)
      # Admin users can modify any product
      return true if current_user&.admin? || current_user&.super_admin?

      # Sellers can only modify their own products
      return current_user&.seller&.id == product.seller_id if current_user&.seller.present?

      # Regular users cannot modify products
      false
    end

    # Only allow a list of trusted parameters through.
    def product_params
      # Get the base parameters that all users can set
      permitted_params = params.require(:product).permit(
        :name, :description, :price, :discounted_price, :stock_quantity,
        :sku, :barcode, :weight, :dimensions, :condition, :brand, :currency,
        :country_of_origin, :available_in_ghana, :available_in_nigeria, :shipping_time,
        :category_id, :published, :published_at, :meta_title, :meta_description,
        :is_digital, :status, :on_sale, :cover_image, :digital_file,
        :product_images_attributes => [:id, :image_url, :_destroy],
        :images => []
      )

      # Only admins can set the featured flag
      if current_user&.admin? || current_user&.super_admin?
        permitted_params.merge!(params.require(:product).permit(:featured))
      end

      # Only allow setting seller_id if admin or if it's the current user's seller id
      if params[:product][:seller_id].present?
        if current_user&.admin? || current_user&.super_admin? ||
           (current_user&.seller&.id.to_s == params[:product][:seller_id])
          permitted_params[:seller_id] = params[:product][:seller_id]
        else
          # Set to current user's seller id if they're a seller
          permitted_params[:seller_id] = current_user&.seller&.id if current_user&.seller.present?
        end
      elsif current_user&.seller.present?
        # Default to current user's seller id if they're a seller
        permitted_params[:seller_id] = current_user.seller.id
      end

      permitted_params
    end

  def deals
    # Find products where discounted_price is less than price - with eager loading to prevent N+1
    @products = Product.where("discounted_price < price AND published = ?", true)
                    .includes(:category, :seller, :product_images)
                    .order(discounted_price: :asc)

    # Use pagination helper for safety
    @products = paginate_safely(@products, params[:page], 12)
    # Add any additional logic you need for the deals page
  end

def new_arrivals
  # Get products published in the last 30 days - with eager loading to prevent N+1
  @new_products = Product.where(published: true)
                      .where("published_at >= ?", 30.days.ago)
                      .includes(:category, :seller, :product_images)
                      .order(published_at: :desc)

  # Use pagination helper for safety
  @new_products = paginate_safely(@new_products, params[:page], 12)
end
end
