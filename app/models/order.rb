class Order < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  belongs_to :payment, optional: true
  belongs_to :shipping_address, optional: true
  belongs_to :billing_address, optional: true
  belongs_to :cart, optional: true
  belongs_to :wishlist, optional: true
  belongs_to :order_status, optional: true
  belongs_to :payment_method, optional: true
  belongs_to :shipping_method, optional: true
  belongs_to :coupon, optional: true

  # Associations
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  has_many :cart_items, dependent: :destroy
  has_many :wishlists, dependent: :destroy
  has_many :product_questions, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :user_activities, as: :reference, dependent: :destroy
  has_many :product_images, dependent: :destroy
  has_many :payment_audit_logs, dependent: :destroy
  has_many :action_items, dependent: :destroy
  has_many :completed_orders, -> { where(status: "completed") }, class_name: "Order"
  has_many :download_links, dependent: :destroy
  has_many :notifications, dependent: :destroy

  # Enums for status
  enum :status, {
    pending: 'pending',
    processing: 'processing',
    paid: 'paid',
    completed: 'completed',
    cancelled: 'cancelled',
    refunded: 'refunded'
  }, default: 'pending'

  # Enums for payment status
  enum :payment_status, {
    pending_payment: 'pending',
    processing_payment: 'processing',
    payment_successful: 'paid',
    payment_failed: 'failed',
    payment_refunded: 'refunded'
  }, default: 'pending'

  # Validations
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :payment_id, presence: true, uniqueness: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :pending_orders, -> { where(status: 'pending') }
  scope :completed_orders, -> { where(status: 'completed') }
  scope :cancelled_orders, -> { where(status: 'cancelled') }
  scope :refunded_orders, -> { where(status: 'refunded') }
  scope :processing_orders, -> { where(status: 'processing') }
  scope :paid_orders, -> { where(status: 'paid') }

  # Callbacks
  before_validation :set_defaults

  # Validations
  validates :user_id, presence: true
  validates :product_id, presence: true

  # Callbacks
  before_validation :set_defaults

  # Callbacks
  before_create :set_default_status
  after_create :generate_download_links, if: -> { product.is_digital? }

  # Methods
  def process_payment!
    update(status: 'processing', payment_status: 'processing_payment')
    # Call payment processing service here
  end

  def mark_as_paid!
    update(status: 'paid', payment_status: 'paid')
    # Send confirmation email
  end

  def mark_as_completed!
    update(status: 'completed')
    # Send fulfillment notification
  end

  def cancel!
    update(status: 'cancelled')
    # Send cancellation email
  end

  def refund!
    update(status: 'refunded', payment_status: 'refunded')
    # Process refund logic
  end

  private

  def set_default_status
    self.status ||= 'pending'
    self.payment_status ||= 'pending'
  end

  def generate_download_links
    return unless product.is_digital?

    # Create a download link for digital products
    expires_at = 30.days.from_now
    download_limit = 5

    DownloadLink.create!(
      product: product,
      user: user,
      order: self,
      token: SecureRandom.hex(16),
      expires_at: expires_at,
      download_count: 0,
      download_limit: download_limit,
      active: true
    )
  end
end
