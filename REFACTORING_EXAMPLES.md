# Refactoring Examples: Mizzby Codebase

This document provides copy-paste ready code examples for refactoring your models.

---

## 1. Extract User Model Concerns

### Current State
`app/models/user.rb` is 275 lines with mixed responsibilities.

### Refactoring Steps

#### Step 1: Create UserAssociations Concern
Create: `app/models/concerns/user_associations.rb`

```ruby
module UserAssociations
  extend ActiveSupport::Concern

  included do
    # Active Storage for profile picture
    has_one_attached :profile_picture

    # Customer relationships
    has_one  :cart, dependent: :destroy
    has_many :cart_items, dependent: :destroy
    has_many :orders, dependent: :restrict_with_error
    has_many :reviews, dependent: :nullify
    has_many :wishlist_items, dependent: :destroy
    has_many :download_links, dependent: :destroy
    has_many :notifications, dependent: :destroy
    has_many :payment_audit_logs, dependent: :nullify
    has_many :user_activities, dependent: :destroy
    has_many :action_items, dependent: :destroy

    # Seller relationship
    has_one :seller, dependent: :destroy
  end
end
```

#### Step 2: Create UserValidations Concern
Create: `app/models/concerns/user_validations.rb`

```ruby
module UserValidations
  extend ActiveSupport::Concern

  included do
    # User information validations
    validates :first_name, :last_name, presence: true, 
                                        length: { minimum: 2, maximum: 50 }

    # Email format validation (additional to Devise's validation)
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, 
                               message: "must be a valid email address" }

    # Custom validation for profile picture
    validate :validate_profile_picture, if: :profile_picture_attached?
  end
end
```

#### Step 3: Create UserCallbacks Concern
Create: `app/models/concerns/user_callbacks.rb`

```ruby
module UserCallbacks
  extend ActiveSupport::Concern

  included do
    before_create :create_cart
    after_create :log_user_activity
    after_update :log_user_activity, if: :saved_changes?
  end

  private

  def create_cart
    build_cart
  end

  def log_user_activity
    UserActivity.create(
      user: self,
      action: 'user_updated',
      details: saved_changes.to_h
    )
  end
end
```

#### Step 4: Create UserScopes Concern
Create: `app/models/concerns/user_scopes.rb`

```ruby
module UserScopes
  extend ActiveSupport::Concern

  class_methods do
    def active
      where(status: :active)
    end

    def with_orders
      joins(:orders).distinct
    end

    def sellers
      joins(:seller)
    end

    def recent(days = 7)
      where('created_at > ?', days.days.ago)
    end
  end
end
```

#### Step 5: Refactor User Model
Update: `app/models/user.rb`

```ruby
class User < ApplicationRecord
  # Include Devise
  devise :database_authenticatable, :registerable, :confirmable, :lockable,
         :recoverable, :rememberable, :validatable, :timeoutable, :trackable

  # Include concerns
  include UserAssociations
  include UserValidations
  include UserCallbacks
  include UserScopes
  include Avatarable

  # Enum declarations
  store_accessor :preferences, :theme, :email_notifications, :marketing_emails,
                 :two_factor_enabled, :currency_preference, :language_preference

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def is_seller?
    seller.present?
  end

  def total_spent
    orders.sum(:total_amount)
  end

  private

  def validate_profile_picture
    if profile_picture.attached?
      unless profile_picture.byte_size <= 5.megabytes
        errors.add(:profile_picture, "must be less than 5MB")
      end

      unless profile_picture.content_type.in?(%w[image/jpeg image/png image/webp])
        errors.add(:profile_picture, "must be JPEG, PNG, or WebP")
      end
    end
  end
end
```

---

## 2. Create Service Objects for Complex Logic

### Example: CartService
Create: `app/services/cart_service.rb`

```ruby
class CartService
  def initialize(cart)
    @cart = cart
  end

  def add_item(product, quantity = 1)
    return error("Product not available") unless product.available?
    return error("Quantity exceeds available stock") if quantity > product.stock

    cart_item = @cart.cart_items.find_or_initialize_by(product: product)
    cart_item.quantity += quantity
    
    if cart_item.save
      success(cart_item)
    else
      error(cart_item.errors.full_messages.join(", "))
    end
  end

  def remove_item(product)
    @cart.cart_items.where(product: product).destroy_all
    success(true)
  end

  def clear_cart
    @cart.cart_items.destroy_all
    success(true)
  end

  def calculate_total
    @cart.cart_items.sum { |item| item.quantity * item.product.price }
  end

  def item_count
    @cart.cart_items.sum(:quantity)
  end

  private

  def success(data)
    { success: true, data: data }
  end

  def error(message)
    { success: false, error: message }
  end
end
```

**Usage:**
```ruby
# In controller
cart = current_user.cart
service = CartService.new(cart)
result = service.add_item(product, 2)

if result[:success]
  redirect_to cart_path, notice: "Item added to cart"
else
  redirect_to cart_path, alert: result[:error]
end
```

### Example: OrderProcessingService
Create: `app/services/order_processing_service.rb`

```ruby
class OrderProcessingService
  def initialize(user, cart)
    @user = user
    @cart = cart
    @errors = []
  end

  def process
    begin
      validate_cart
      validate_inventory
      process_payment
      create_order
      send_confirmation_email
      clear_cart
      
      { success: true, order: @order }
    rescue => e
      { success: false, error: e.message }
    end
  end

  private

  def validate_cart
    raise "Cart is empty" if @cart.cart_items.empty?
  end

  def validate_inventory
    @cart.cart_items.each do |item|
      unless item.product.has_stock?(item.quantity)
        raise "#{item.product.name} has insufficient stock"
      end
    end
  end

  def process_payment
    # Integrate with payment gateway (Stripe, PayPal, etc.)
    payment = PaymentProcessor.charge(
      user: @user,
      amount: calculate_total,
      token: @user.payment_token
    )
    raise "Payment failed: #{payment.error}" unless payment.success?
  end

  def create_order
    @order = Order.create!(
      user: @user,
      total_amount: calculate_total,
      status: 'pending'
    )

    @cart.cart_items.each do |item|
      OrderItem.create!(
        order: @order,
        product: item.product,
        quantity: item.quantity,
        price: item.product.price
      )

      # Deduct from inventory
      item.product.update(stock: item.product.stock - item.quantity)
    end
  end

  def send_confirmation_email
    OrderMailer.confirmation_email(@user, @order).deliver_later
  end

  def clear_cart
    @cart.cart_items.destroy_all
  end

  def calculate_total
    @cart.cart_items.sum { |item| item.quantity * item.product.price }
  end
end
```

**Usage:**
```ruby
# In OrdersController
def create
  result = OrderProcessingService.new(current_user, current_user.cart).process
  
  if result[:success]
    redirect_to result[:order], notice: "Order created successfully"
  else
    redirect_to cart_path, alert: result[:error]
  end
end
```

---

## 3. Extract Validations to Custom Validators

### Example: Email Validator
Create: `app/validators/email_validator.rb`

```ruby
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    unless value.match?(URI::MailTo::EMAIL_REGEXP)
      record.errors.add(attribute, (options[:message] || "is not a valid email"))
    end
  end
end
```

**Usage:**
```ruby
# In models
class User < ApplicationRecord
  validates :email, email: true
end
```

### Example: File Size Validator
Create: `app/validators/file_size_validator.rb`

```ruby
class FileSizeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    max_size = options[:maximum]
    return unless max_size

    if value.byte_size > max_size
      record.errors.add(
        attribute, 
        "must be less than #{format_bytes(max_size)}"
      )
    end
  end

  private

  def format_bytes(bytes)
    case bytes
    when 0...1024
      "#{bytes}B"
    when 1024...1024**2
      "#{(bytes / 1024).round(2)}KB"
    else
      "#{(bytes / (1024**2)).round(2)}MB"
    end
  end
end
```

**Usage:**
```ruby
class User < ApplicationRecord
  has_one_attached :profile_picture
  validates :profile_picture, file_size: { maximum: 5.megabytes }
end
```

---

## 4. Create Query Objects for Complex Queries

### Example: Product Listing Query
Create: `app/queries/product_list_query.rb`

```ruby
class ProductListQuery
  def initialize(relation = Product.all)
    @relation = relation
  end

  def by_category(category_id)
    @relation = @relation.where(category_id: category_id)
    self
  end

  def by_price_range(min, max)
    @relation = @relation.where('price >= ? AND price <= ?', min, max)
    self
  end

  def by_rating(min_rating)
    @relation = @relation.joins(:reviews)
                          .group('products.id')
                          .having('AVG(reviews.rating) >= ?', min_rating)
    self
  end

  def in_stock
    @relation = @relation.where('stock > 0')
    self
  end

  def featured
    @relation = @relation.where(featured: true)
    self
  end

  def sorted(field = 'created_at', direction = 'desc')
    @relation = @relation.order("#{field} #{direction}")
    self
  end

  def paginated(page = 1, per_page = 20)
    @relation = @relation.limit(per_page).offset((page - 1) * per_page)
    self
  end

  def call
    @relation.includes(:images, :reviews, :category).distinct
  end
end
```

**Usage:**
```ruby
# In ProductsController
def index
  @products = ProductListQuery.new
    .by_category(params[:category])
    .by_price_range(params[:min_price], params[:max_price])
    .in_stock
    .sorted(params[:sort], params[:direction])
    .paginated(params[:page])
    .call
end
```

---

## 5. Fix Common Issues

### Fix 1: Remove Contradictory Validations
**Before:**
```ruby
validates :first_name, :last_name, presence: true, allow_blank: true
```

**After:**
```ruby
validates :first_name, :last_name, presence: true
```

### Fix 2: Add Proper Association Dependencies
**Before:**
```ruby
has_many :orders
```

**After:**
```ruby
has_many :orders, dependent: :restrict_with_error  # Prevent deletion if orders exist
has_many :cart_items, dependent: :destroy  # Auto-delete when user deleted
```

### Fix 3: Add Database Indexes
Create migration: `db/migrate/[timestamp]_add_indexes.rb`

```ruby
class AddIndexes < ActiveRecord::Migration[8.0]
  def change
    add_index :users, :email, unique: true
    add_index :orders, :user_id
    add_index :cart_items, [:cart_id, :product_id], unique: true
    add_index :products, :category_id
    add_index :products, :seller_id
    add_index :reviews, :product_id
  end
end
```

---

## 6. Add Scope Methods to Models

### Example: Product Scopes
```ruby
class Product < ApplicationRecord
  scope :featured, -> { where(featured: true) }
  scope :in_stock, -> { where('stock > 0') }
  scope :popular, -> { joins(:reviews).group('products.id').order('AVG(reviews.rating) DESC') }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :price_range, ->(min, max) { where('price BETWEEN ? AND ?', min, max) }

  # Chainable scopes
  scope :active, -> { where(status: :active) }
end
```

**Usage:**
```ruby
Product.featured.in_stock.recent.limit(10)
Product.by_category(5).price_range(10, 100)
```

---

## Testing Examples

### Model Test with Service
Create: `test/services/cart_service_test.rb`

```ruby
require "test_helper"

class CartServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @product = products(:one)
    @cart = @user.cart || @user.create_cart
    @service = CartService.new(@cart)
  end

  test "adds item to cart" do
    result = @service.add_item(@product, 2)
    
    assert result[:success]
    assert_equal 2, @cart.cart_items.find_by(product: @product).quantity
  end

  test "returns error when product unavailable" do
    @product.update(stock: 0)
    result = @service.add_item(@product, 1)
    
    refute result[:success]
    assert_match /insufficient stock/i, result[:error]
  end

  test "calculates total correctly" do
    @service.add_item(@product, 2)
    total = @service.calculate_total
    
    assert_equal @product.price * 2, total
  end
end
```

---

**Last Updated:** November 24, 2025
