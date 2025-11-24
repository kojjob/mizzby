class OrderItem < ApplicationRecord
  # Associations
  belongs_to :order
  belongs_to :product

  # Validations
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_validation :calculate_total_price

  # Calculate total price before validation
  def calculate_total_price
    self.total_price = quantity * unit_price if quantity.present? && unit_price.present?
  end

  # Optional scope
  scope :gifts, -> { where(is_gift: true) }

  # Instance method to check if customized
  def customized?
    customization_notes.present?
  end
end
