class Product < ApplicationRecord
  belongs_to :category
  belongs_to :seller

  # Add these methods to your Product model if they don't already exist
  def discounted_price
    return price unless on_sale?
    (price * (1 - (discount_percentage / 100.0))).round(2)
  end

  def on_sale?
    on_sale && discount_percentage.present? && discount_percentage > 0
  end

  scope :active, -> { where(active: true) }
end
