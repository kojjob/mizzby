class Category < ApplicationRecord
  # Relationships
  has_many :subcategories, class_name: "Category", foreign_key: "parent_id", dependent: :destroy
  belongs_to :parent, class_name: "Category", optional: true
  has_many :products, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :slug, presence: true, uniqueness: true

  # Callbacks
  before_validation :set_slug, if: -> { name.present? && slug.blank? }

  # Scopes
  scope :visible, -> { where(visible: true) }
  scope :ordered, -> { order(position: :asc) }
  scope :roots, -> { where(parent_id: nil) }

  # Methods
  def ancestors
    result = []
    current = self

    while current.parent
      result << current.parent
      current = current.parent
    end

    result.reverse
  end

  def root?
    parent_id.nil?
  end

  def leaf?
    subcategories.empty?
  end

  def depth
    root? ? 0 : ancestors.size
  end

  def full_path
    (ancestors + [ self ]).map(&:name).join(" > ")
  end

  def items_count
    products.count
  end

  private

  def set_slug
    self.slug = name.parameterize
  end
end
