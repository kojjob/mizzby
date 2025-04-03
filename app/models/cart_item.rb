class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  
  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validate :product_available
  
  before_save :update_price
  after_save :update_cart_total
  after_destroy :update_cart_total
  
  # Calculate subtotal for this item
  def subtotal
    quantity * price
  end
  
  private
  
  # Ensure price matches current product price or discount price
  def update_price
    self.price = product.discounted_price.present? ? product.discounted_price : product.price
  end
  
  # Update the cart's total after changes
  def update_cart_total
    cart.update_total_price!
  end
  
  # Validate product is in stock (for physical products)
  def product_available
    return if product.is_digital
    if product.stock_quantity < quantity
      errors.add(:quantity, "exceeds available stock (#{product.stock_quantity} available)")
    end
  end
end