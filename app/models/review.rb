class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product

  # Validations
  validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :content, presence: true, length: { minimum: 10, maximum: 1000 }

  # Ensure user can only review a product once
  validates :product_id, uniqueness: { scope: :user_id, message: "has already been reviewed by you" }

  # Scopes
  scope :published, -> { where(published: true) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  after_save :clear_product_cache
  after_destroy :clear_product_cache

  private

  def clear_product_cache
    # Clear cached product rating and review count
    Rails.cache.delete("product_#{product_id}_avg_rating")
    Rails.cache.delete("product_#{product_id}_reviews_count")
  end
end
