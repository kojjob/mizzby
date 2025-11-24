class Product < ApplicationRecord
  # Associations
  belongs_to :category
  belongs_to :seller
  # brand is a string attribute, not an association
  has_many :product_images, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :product_questions, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_many :cart_items, dependent: :destroy
  # This association was incorrect - we have wishlist_items, not wishlists
  # has_many :wishlists, dependent: :destroy
  has_many :carts, through: :cart_items
  has_many :wishlist_items, dependent: :destroy
  has_many :user_activities, as: :reference, dependent: :destroy
  # Products can be notifiable, but don't have direct notifications
  # has_many :notifications, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :download_links, dependent: :destroy
  # Products don't have direct payment_audit_logs
  # has_many :payment_audit_logs, dependent: :destroy
  # Products don't have direct action_items
  # has_many :action_items, dependent: :destroy
  has_many :completed_orders, -> { where(status: "completed") }, class_name: "Order"
  has_many :completed_order_items, through: :completed_orders, source: :order_items

  # Enum for product status
  enum :status, { inactive: 0, active: 1, archived: 2 }, prefix: true

  # Enum for product type
  enum :product_type, { physical: 0, digital: 1 }, prefix: true

  # Enum for sale status
  enum :sale_status, { on_sale: 0, not_on_sale: 1 }, prefix: true

  # Enum for featured status
  enum :featured, { no: false, yes: true }, prefix: true


  # Validate slug is present and unique
  validates :slug, presence: true, uniqueness: true
  validates :name, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :brand, presence: true
  validates :category, presence: true
  validates :sku, presence: true, uniqueness: true
  validates :meta_title, presence: true
  validates :meta_description, presence: true
  validates :specifications, length: { maximum: 10000 }, allow_nil: true


  before_validation :set_slug, on: :create
  before_save :update_sale_status

  # Add Active Storage attachment for digital file
  has_one_attached :digital_file
  has_one_attached :cover_image
  has_many_attached :image_urls
  has_many_attached :images

  # Define scopes
  scope :featured, -> { where(featured: true) }
  scope :on_sale, -> { where(on_sale: true) }
  scope :digital, -> { where(is_digital: true) }
  scope :physical, -> { where(is_digital: false) }
  scope :search_by_name, ->(query) { where("name ILIKE ?", "%#{sanitize_sql_like(query)}%") if query.present? }
  scope :active, -> { where(status: "active") }
  scope :published, -> { where(published: true) }
  scope :by_category, ->(category_id) { where(category_id: category_id) if category_id.present? }
  scope :by_seller, ->(seller_id) { where(seller_id: seller_id) if seller_id.present? }
  scope :in_stock, -> { where("stock_quantity > ?", 0) }
  scope :price_range, ->(min, max) { where(price: min..max) if min.present? && max.present? }

  # Define a method to get the first image URL
  def image_url
    images.attached? ? images.first : cover_image
  end

  # Define a method to get the first image URL
  def thumbnail_url
    if product_images.any? && product_images.first.image.attached?
      product_images.first.image
    elsif cover_image.attached?
      cover_image
    else
      nil
    end
  end

  # Add these methods to your Product model if they don't already exist
  # Fix the discounted_price method
  def discounted_price
    self[:discounted_price] || price
  end

  # Fix the on_sale? method to not rely on on_sale attribute
  def on_sale?
    discounted_price.present? && price.present? && discounted_price < price
  end

  # Calculate discount percentage
  def discount_percentage
    return 0 unless price.present? && discounted_price.present? && price > 0 && discounted_price < price
    ((price - discounted_price) / price * 100).round(1)
  end

  # Calculate average rating (with caching to avoid N+1)
  def average_rating
    Rails.cache.fetch("product_#{id}_avg_rating", expires_in: 1.hour) do
      reviews.average(:rating)&.to_f
    end
  end

  # Get review count (with caching)
  def reviews_count
    Rails.cache.fetch("product_#{id}_reviews_count", expires_in: 1.hour) do
      reviews.count
    end
  end

  # validates :image, content_type: ['image/png', 'image/jpeg', 'image/jpg'],
  #         size: { less_than: 5.megabytes },
  #         if: :image_attached?

  # Method to provide a display image (either from product images, cover image, or a placeholder)
  def display_image
    if product_images.any? && product_images.first.image.attached?
      product_images.first.image
    elsif cover_image.attached?
      cover_image
    elsif image.attached?
      image
    else
      "placeholder-product.png"
    end
  end

  private

  def image_attached?
    image.attached?
  end

  def update_sale_status
    # Only update if the database has an on_sale column
    if Product.column_names.include?("on_sale")
      self.on_sale = discounted_price.present? && price.present? && discounted_price < price
    end
  end

  def set_slug
    return if slug.present? || name.blank?

    # Create a base slug from the product name
    base_slug = name.parameterize

    # Check if the slug already exists
    new_slug = base_slug
    counter = 0

    # If the slug exists, append a number until it's unique
    while Product.where(slug: new_slug).where.not(id: id).exists?
      counter += 1
      new_slug = "#{base_slug}-#{counter}"
    end

    self.slug = new_slug
  end
end
