class Seller < ApplicationRecord
  belongs_to :user
  has_many :products, dependent: :destroy
  has_many :orders, through: :products
  has_one :store, dependent: :destroy
  after_create :create_default_store

  # Validations for store fields
  validates :store_name, presence: true, if: :store_enabled?
  validates :store_slug, presence: true, uniqueness: true,
            format: { with: /\A[a-z0-9\-_]+\z/, message: "can only contain lowercase letters, numbers, hyphens and underscores" },
            if: :store_enabled?
  validates :custom_domain, uniqueness: true, allow_blank: true,
            format: { with: /\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,}\z/i, message: "is not a valid domain" }

  # Callbacks
  before_validation :generate_store_slug, if: -> { store_name.present? && store_slug.blank? }

  # Helper method to check if seller is verified
  def verified?
    verified.present? && verified
  end

  # Helper method to get the business name or a fallback
  def name
    business_name.presence || "Seller ##{id}"
  end

  # Store-related methods
  def store_enabled?
    store_settings.present? && store_settings["enabled"] == true
  end

  def store_url
    if custom_domain.present? && domain_verified?
      "https://#{custom_domain}"
    else
      Rails.application.routes.url_helpers.store_url(store_slug, host: Rails.application.config.action_mailer.default_url_options[:host])
    end
  end

  def domain_verified?
    domain_verified.present? && domain_verified
  end

  private

  def generate_store_slug
    return if store_name.blank?

    # Generate a slug from the store name
    base_slug = store_name.parameterize

    # Check if the slug is already taken
    if Seller.where(store_slug: base_slug).where.not(id: id).exists?
      # Add a random suffix
      self.store_slug = "#{base_slug}-#{SecureRandom.hex(3)}"
    else
      self.store_slug = base_slug
    end
  end

  def create_default_store
    # Automatically create a store when a seller is created
    store_name = business_name.presence || "#{user.first_name}'s Store"
    create_store(
      name: store_name,
      slug: store_name.parameterize,
      theme: "default",
      color_scheme: "light",
      published: true
    )
  end

end
