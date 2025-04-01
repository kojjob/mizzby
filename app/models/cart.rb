class Cart < ApplicationRecord
  belongs_to :user, optional: true

  # Add this line to establish the relationship with cart items
  has_many :cart_items, dependent: :destroy

  # You might also want to add this for convenience
  has_many :products, through: :cart_items
end
