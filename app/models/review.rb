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
  after_save :update_product_rating, if: :saved_change_to_rating?
  
  private
  
  def update_product_rating
    # This is a placeholder for implementing cache counters if needed
    # For now, we'll use the average_rating method in the Product model
  end
end