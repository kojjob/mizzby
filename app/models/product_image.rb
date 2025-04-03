class ProductImage < ApplicationRecord
  belongs_to :product

  # Add Active Storage attachment for image
  has_one_attached :image

  # Validations
  validates :product, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  # Default scope for ordering by position
  default_scope { order(position: :asc) }

  # Method to get the image URL for use in views
  def image_url
    image.attached? ? image : nil
  end

  # Generate a default alt text if none is provided
  before_save :set_default_alt_text

  private

  def set_default_alt_text
    self.alt_text ||= "#{product.name} - Image #{position || 1}" if product
  end
end
