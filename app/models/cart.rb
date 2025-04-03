class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  # Status enum for tracking cart state
  enum :status, { active: "active", abandoned: "abandoned", converted: "converted" }

  validates :cart_id, uniqueness: true, allow_nil: true

  # Calculate total price
  def total_price
    cart_items.sum { |item| item.subtotal }
  end
  
  # Calculate shipping cost (can be customized based on your business logic)
  def shipping_cost
    products.where(is_digital: false).any? ? 10.0 : 0.0
  end
  
  # Grand total including shipping
  def grand_total
    total_price + shipping_cost
  end
  
  # Count items in cart
  def item_count
    cart_items.sum(:quantity)
  end
  
  # Check if cart has digital products
  def has_digital_products?
    products.where(is_digital: true).any?
  end
  
  # Check if cart has physical products
  def has_physical_products?
    products.where(is_digital: false).any?
  end
  
  # Empty the cart
  def empty!
    cart_items.destroy_all
    update(total_price: 0)
  end
  
  # Update cart total price
  def update_total_price!
    update(total_price: total_price)
  end
end