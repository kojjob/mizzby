module SchemaValidations
  extend ActiveSupport::Concern

  included do
    # Apply common validations based on model name
    case self.name
    when "Review"
      validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
      validates :user_id, uniqueness: { scope: :product_id, message: "has already reviewed this product" }

    when "Product"
      validates :slug, presence: true, uniqueness: true
      validates :sku, presence: true, uniqueness: true
      validates :barcode, presence: true, uniqueness: true
      validates :price, numericality: { greater_than_or_equal_to: 0 }
      validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :name, :meta_title, :meta_description, :brand, :country_of_origin, presence: true

    when "Order"
      validates :status, inclusion: { in: %w[pending processing paid completed cancelled refunded] }
      validates :payment_status, inclusion: { in: %w[pending processing paid failed refunded] }
      validates :total_amount, numericality: { greater_than_or_equal_to: 0 }

    when "Category"
      validates :name, presence: true
      validates :slug, presence: true, uniqueness: true
      validate :parent_cannot_be_self
      validate :parent_cannot_be_descendant

    when "CartItem"
      validates :quantity, numericality: { only_integer: true, greater_than: 0 }

    when "Seller"
      validates :business_name, presence: true
      validates :user_id, uniqueness: true
    end
  end

  # Custom validations
  def parent_cannot_be_self
    if parent_id == id && !id.nil?
      errors.add(:parent_id, "cannot be the same as the category itself")
    end
  end

  def parent_cannot_be_descendant
    return unless parent_id && id

    current = self.class.find_by(id: parent_id)
    while current
      if current.parent_id == id
        errors.add(:parent_id, "cannot be a descendant of this category")
        break
      end
      current = current.parent_id ? self.class.find_by(id: current.parent_id) : nil
    end
  end
end
