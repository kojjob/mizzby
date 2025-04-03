class DealsController < ApplicationController
  def index
    # Get products with discounts
    @products = Product.on_sale
                      .order(Arel.sql('(price - discounted_price) / price * 100 DESC'))
                      .limit(24)
    
    # Fetch featured deals if any
    @featured_deals = Product.on_sale
                            .where(featured: true)
                            .order(Arel.sql('(price - discounted_price) / price * 100 DESC'))
                            .limit(4)
  end
end
