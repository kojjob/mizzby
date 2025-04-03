class WishlistItem < ApplicationRecord
  belongs_to :user
  belongs_to :product
  
  # Validations
  validates :product_id, uniqueness: { scope: :user_id, message: "is already in your wishlist" }
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  
  # Methods
  def move_to_cart
    cart = user.cart || user.create_cart(user_id: user.id) # Ensure user_id is set

    if cart.cart_items.exists?(product_id: product_id)
      return false, "Product is already in your cart"
    end

    # Add to cart
    price = product.discounted_price.present? ? product.discounted_price : product.price
    cart_item = cart.cart_items.create(product_id: product_id, quantity: 1, price: price)

    if cart_item.persisted?
      # If successfully added to cart, remove from wishlist
      destroy
      return true, "Product moved to cart"
    else
      return false, cart_item.errors.full_messages.join(", ")
    end
  end
end
