class DealsController < ApplicationController
  def index
    # Use published instead of active/status
    base_query = Product.where(published: true)
                        .where("discounted_price < price")
                        .order(discounted_price: :asc)

    # Simple pagination without relying on Kaminari config
    @page = (params[:page] || 1).to_i
    @per_page = 12
    @deals = base_query.limit(@per_page).offset((@page - 1) * @per_page)

    # For pagination links
    @total_count = base_query.count
    @total_pages = (@total_count.to_f / @per_page).ceil

    @featured_deals = Product.where(published: true, featured: true)
                             .where("discounted_price < price")
                             .limit(3)
  end
end
