# app/controllers/stores_controller.rb
class StoresController < ApplicationController
  before_action :set_store, only: [ :show, :products, :about, :contact, :categories ]

  def index
    @stores = Store.all

    # Search functionality
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @stores = @stores.where("name ILIKE ? OR description ILIKE ?", search_term, search_term)
    end

    # Sorting functionality
    if params[:sort].present?
      case params[:sort]
      when "newest"
        @stores = @stores.order(created_at: :desc)
      when "alphabetical"
        @stores = @stores.order(name: :asc)
      when "popular"
        # This would ideally use a more sophisticated popularity metric
        # For now, we'll use the number of products as a proxy for popularity
        @stores = @stores.left_joins(seller: :products)
                         .group(:id)
                         .order("COUNT(products.id) DESC")
      end
    else
      # Default sorting
      @stores = @stores.order(created_at: :desc)
    end

    # Pagination
    @stores = @stores.page(params[:page]).per(24)

    # Get featured stores for the carousel
    # In a real app, you might have a featured flag or use some other criteria
    @featured_stores = Store.order(created_at: :desc).limit(5)
  end

  def show
    # Check if the store has the necessary methods
    @featured_products = @store.respond_to?(:featured_products) ? @store.featured_products.limit(8) : []
    @recent_products = @store.respond_to?(:recent_products) ? @store.recent_products.limit(8) : []
    @categories = @store.respond_to?(:store_categories) ? @store.store_categories.order(position: :asc) : []
  rescue => e
    # Log the error
    Rails.logger.error("Error in store show page: #{e.message}\n#{e.backtrace.join("\n")}")

    # Set default values
    @featured_products = []
    @recent_products = []
    @categories = []
  end

  def products
    @products = @store.products.page(params[:page]).per(24)

    if params[:category_id].present?
      @category = @store.store_categories.find(params[:category_id])
      @products = @products.where(category_id: @category.id)
    end

    if params[:sort].present?
      case params[:sort]
      when "price_asc"
        @products = @products.order(price: :asc)
      when "price_desc"
        @products = @products.order(price: :desc)
      when "newest"
        @products = @products.order(created_at: :desc)
      when "popularity"
        @products = @products.left_joins(:orders).group(:id).order("COUNT(orders.id) DESC")
      end
    end
  end

  def about
    # Show the about page for the store
  end

  def contact
    # Show the contact page for the store
  end

  private

  def set_store
    @store = Store.find_by!(slug: params[:slug])
    @seller = @store.seller if @store.present?
  end
end
