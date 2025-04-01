class Category < ApplicationRecord
  # Assuming you already have relationships set up
  # If not, you'll need to add:
  has_many :subcategories, class_name: "Category", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Category", optional: true

  # Add this class method to find root categories
  def self.roots
    where(parent_id: nil)
  end
end
