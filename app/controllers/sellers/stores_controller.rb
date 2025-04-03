module Sellers
  class StoresController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_seller
    before_action :set_store
    
    def edit
      # Show store edit form
    end
    
    def update
      if @store.update(store_params)
        # Handle successful update
        redirect_to edit_sellers_store_path, notice: 'Store updated successfully'
      else
        render :edit
      end
    end
    
    def theme
      # Theme customization interface
    end
    
    def update_theme
      if @store.update(theme_params)
        redirect_to theme_sellers_store_path, notice: 'Theme updated successfully'
      else
        render :theme
      end
    end
    
    def categories
      @store_categories = @store.store_categories.order(position: :asc)
    end
    
    def analytics
    # Store analytics dashboard
    @recent_orders = current_seller.orders.recent.limit(10)
    
    # Check if ProductView model exists before using it
    if defined?(ProductView)
      @product_views = ProductView.where(product_id: current_seller.product_ids)
    .group(:product_id)
    .count
    else
        @product_views = {}
      end
      
      @top_products = current_seller.products.left_joins(:orders)
                                 .group(:id)
                                 .order('COUNT(orders.id) DESC')
                                 .limit(5)
    end
    
    private
    
    def ensure_seller
      redirect_to new_seller_path unless current_user.seller?
    end
    
    def set_store
      @store = current_user.seller.store
    end
    
    def store_params
      params.require(:store).permit(:name, :description, :custom_domain, 
                                   :meta_title, :meta_description, :logo, 
                                   :banner_image, :published)
    end
    
    def theme_params
      params.require(:store).permit(:theme, :color_scheme, :custom_css, 
                                   :show_featured_products, theme_images: [])
    end
  end
end