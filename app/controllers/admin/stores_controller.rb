module Admin
  class StoresController < BaseController
    before_action :set_store, only: [ :show, :edit, :update, :destroy ]

    def index
      @stores = Store.includes(:seller).all

      # Search functionality
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @stores = @stores.where("name ILIKE ? OR slug ILIKE ?", search_term, search_term)
      end

      # Sorting functionality
      if params[:sort].present?
        case params[:sort]
        when "newest"
          @stores = @stores.order(created_at: :desc)
        when "alphabetical"
          @stores = @stores.order(name: :asc)
        when "seller"
          @stores = @stores.joins(:seller).order("sellers.business_name ASC")
        end
      else
        @stores = @stores.order(created_at: :desc)
      end

      # Pagination
      @stores = @stores.page(params[:page]).per(10)
    end

    def show
      # Additional data for the store dashboard
      @products_count = @store.products.count
      @recent_products = @store.recent_products(5)
      @store_settings = @store.store_settings
    end

    def new
      @store = Store.new
      @sellers = Seller.all
    end

    def create
      @store = Store.new(store_params)

      if @store.save
        redirect_to admin_store_path(@store), notice: "Store was successfully created."
      else
        @sellers = Seller.all
        render :new
      end
    end

    def edit
      @sellers = Seller.all
    end

    def update
      if @store.update(store_params)
        redirect_to admin_store_path(@store), notice: "Store was successfully updated."
      else
        @sellers = Seller.all
        render :edit
      end
    end

    def destroy
      @store.destroy
      redirect_to admin_stores_path, notice: "Store was successfully deleted."
    end

    private

    def set_store
      @store = Store.find(params[:id])
    end

    def store_params
      params.require(:store).permit(:name, :slug, :description, :seller_id, :theme, :color_scheme, :published, :logo, :banner_image)
    end
  end
end
