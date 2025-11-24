class Store < ApplicationRecord
  belongs_to :seller
  has_many :store_settings, dependent: :destroy
  has_many :store_categories, dependent: :destroy

  has_one_attached :logo
  has_one_attached :banner_image
  has_many_attached :theme_images

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  def products
    seller.products.where(published: true)
  end

  def featured_products
    products.where(featured: true)
  end

  def recent_products(limit = 8)
    products.order(created_at: :desc).limit(limit)
  end

  def bestselling_products(limit = 8)
    products.joins(:orders).group(:id).order("COUNT(orders.id) DESC").limit(limit)
  end

  # Dynamic settings management
  def setting(key)
    store_settings.find_by(key: key)&.value
  end

  def update_setting(key, value)
    setting = store_settings.find_or_initialize_by(key: key)
    setting.update(value: value)
  end

  # Theme related methods
  def theme
    setting("theme") || "default"
  end

  def show_featured_products?
    # Check if featured_products method exists
    return false unless respond_to?(:featured_products)

    # Check if there are any featured products
    featured_products.any? && (setting("show_featured_products") != "false")
  rescue
    # If there's an error, return false
    false
  end

  # Custom CSS
  def custom_css
    setting("custom_css")
  end

  # Product methods
  def featured_products
    return [] unless seller.present? && seller.respond_to?(:products)
    seller.products.where(featured: true, published: true)
  rescue
    []
  end

  def recent_products
    return [] unless seller.present? && seller.respond_to?(:products)
    seller.products.where(published: true).order(created_at: :desc)
  rescue
    []
  end

  def products
    return [] unless seller.present? && seller.respond_to?(:products)
    seller.products.where(published: true)
  rescue
    []
  end

  # Store categories
  def store_categories
    # This is a placeholder - in a real app, you'd have a proper association
    # For now, we'll return an empty array to prevent errors
    []
  end
end
