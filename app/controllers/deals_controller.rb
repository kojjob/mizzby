class DealsController < ApplicationController
  def index
    # Get products with discounts
    @products = Product.on_sale
                      .order(Arel.sql("(price - discounted_price) / price * 100 DESC"))
                      .limit(24)

    # Fetch featured deals if any
    @featured_deals = Product.on_sale
                            .where(featured: true)
                            .order(Arel.sql("(price - discounted_price) / price * 100 DESC"))
                            .limit(4)
  end

  def flash_sales
    # Flash sales - highest discounts, time-limited
    @products = Product.on_sale
                      .order(Arel.sql("(price - discounted_price) / price * 100 DESC"))
                      .limit(24)
    @page_title = "Flash Sales"
    @page_description = "Limited time offers with massive discounts!"
  end

  def clearance
    # Clearance - deeply discounted items
    @products = Product.on_sale
                      .where("discounted_price < price * 0.5") # 50%+ off
                      .order(discounted_price: :asc)
                      .limit(24)
    @page_title = "Clearance"
    @page_description = "Deep discounts on selected items"
  end

  def bundles
    # Bundles - products that are part of bundles or multi-packs
    @products = Product.where("name ILIKE ? OR description ILIKE ?", "%bundle%", "%bundle%")
                      .or(Product.where("name ILIKE ? OR description ILIKE ?", "%pack%", "%pack%"))
                      .order(created_at: :desc)
                      .limit(24)
    @page_title = "Bundles & Packs"
    @page_description = "Save more when you buy together"
  end

  def weekly_offers
    # Weekly offers - rotating deals
    @products = Product.on_sale
                      .order(updated_at: :desc)
                      .limit(24)
    @page_title = "Weekly Offers"
    @page_description = "Fresh deals every week"
  end
end
