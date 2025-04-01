module Admin
  class ProductsController < BaseController
    before_action :set_product, only: [ :show, :edit, :update, :destroy, :toggle_featured, :toggle_status ]
    before_action -> { authorize_action(:manage_products) }
    before_action -> { authorize_action(:delete_products) }, only: [ :destroy ]

    def index
      @products = Product.includes(:category, :seller)
                        .order(created_at: :desc)
                        .page(params[:page])
                        .per(25)

      # Filter by category
      @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?

      # Filter by seller
      @products = @products.where(seller_id: params[:seller_id]) if params[:seller_id].present?

      # Filter by status
      @products = @products.where(status: params[:status]) if params[:status].present?

      # Filter by type (digital/physical)
      @products = @products.where(is_digital: params[:type] == "digital") if params[:type].present?

      # Filter by featured
      @products = @products.where(featured: params[:featured] == "true") if params[:featured].present?

      # Search by name or description
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @products = @products.where("name ILIKE ? OR description ILIKE ?", search_term, search_term)
      end

      # Price range filter
      if params[:min_price].present?
        @products = @products.where("price >= ?", params[:min_price].to_f)
      end

      if params[:max_price].present?
        @products = @products.where("price <= ?", params[:max_price].to_f)
      end
    end

    def show
      @product_images = @product.product_images.order(position: :asc)
      @reviews = @product.reviews.includes(:user).order(created_at: :desc).limit(5)
      @orders = Order.where(product_id: @product.id).order(created_at: :desc).limit(10)
    end

    def new
      @product = Product.new
    end

    def create
      @product = Product.new(product_params)

      if @product.save
        # Handle product images if provided
        if params[:product][:images].present?
          params[:product][:images].each do |image|
            @product.product_images.create(image: image)
          end
        end

        flash[:success] = "Product was successfully created."
        redirect_to admin_product_path(@product)
      else
        flash.now[:error] = "There was a problem creating the product."
        render :new
      end
    end

    def edit
      @product_images = @product.product_images.order(position: :asc)
    end

    def update
      if @product.update(product_params)
        # Handle product images if provided
        if params[:product][:images].present?
          params[:product][:images].each do |image|
            @product.product_images.create(image: image)
          end
        end

        flash[:success] = "Product was successfully updated."
        redirect_to admin_product_path(@product)
      else
        @product_images = @product.product_images.order(position: :asc)
        flash.now[:error] = "There was a problem updating the product."
        render :edit
      end
    end

    def destroy
      if @product.destroy
        flash[:success] = "Product was successfully deleted."
      else
        flash[:error] = "Product could not be deleted: #{@product.errors.full_messages.join(', ')}"
      end

      redirect_to admin_products_path
    end

    def toggle_featured
      @product.update(featured: !@product.featured)

      respond_to do |format|
        format.html do
          flash[:success] = "Product featured status updated."
          redirect_to admin_product_path(@product)
        end
        format.json { render json: { featured: @product.featured } }
      end
    end

    def toggle_status
      # Toggle between active and inactive
      new_status = @product.status == "active" ? "inactive" : "active"
      @product.update(status: new_status)

      respond_to do |format|
        format.html do
          flash[:success] = "Product status updated to #{new_status}."
          redirect_to admin_product_path(@product)
        end
        format.json { render json: { status: @product.status } }
      end
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(
        :name, :description, :price, :discounted_price, :stock_quantity,
        :sku, :barcode, :weight, :dimensions, :condition, :brand, :featured,
        :currency, :country_of_origin, :available_in_ghana, :available_in_nigeria,
        :shipping_time, :category_id, :seller_id, :published, :published_at,
        :meta_title, :meta_description, :is_digital, :status
      )
    end
  end
end
