# Mizzby E-Commerce Enhancement Roadmap

**Created:** November 26, 2025  
**Branch:** feature/codebase-optimization-and-bug-fixes  
**PR:** #49

---

## Priority 1: Coupon/Discount System

### Status: 🔴 Not Started

### Tasks:
- [ ] Create `Coupon` model with migration
  - code (unique string)
  - discount_type (percentage/fixed)
  - discount_value (decimal)
  - minimum_order_amount (optional)
  - max_uses (optional)
  - uses_count
  - starts_at, expires_at
  - active (boolean)
  - applies_to (all/category/product)
- [ ] Create `CouponUsage` model to track per-user usage
- [ ] Add coupon input field to checkout form
- [ ] Integrate coupon validation in `CheckoutController#create`
- [ ] Create admin UI for managing coupons
- [ ] Add coupon display on order confirmation

---

## Priority 2: Seller Store Pages & Messaging System

### Status: 🔴 Not Started

### Tasks:

#### Messaging System
- [ ] Create `Conversation` model
  - buyer_id (user reference)
  - seller_id (seller reference)
  - subject (optional)
  - last_message_at
  - status (active/archived)
- [ ] Create `Message` model
  - conversation_id
  - sender_id (user reference)
  - body (text)
  - read_at (timestamp)
  - attachments (Active Storage)
- [ ] Create `ConversationsController` with inbox, show, create
- [ ] Create `MessagesController` with create action
- [ ] Add routes for conversations and messages
- [ ] Create Stimulus `chat_controller.js` for real-time updates
- [ ] Add Turbo Streams for live message delivery
- [ ] Create inbox views for customers (`account/messages/`)
- [ ] Create inbox views for sellers (`seller/messages/`)
- [ ] Add unread message badges to navbar

#### Enhanced Store Pages
- [ ] Redesign `stores/show.html.erb` with modern hero section
- [ ] Add seller bio/about section with photo
- [ ] Add "Chat with Seller" button on store pages
- [ ] Add "Contact Seller" button on product pages
- [ ] Improve product showcase grid
- [ ] Add seller ratings/reviews summary
- [ ] Add social media links for sellers

---

## Priority 3: Complete Email Notification System

### Status: 🔴 Not Started

### Tasks:
- [ ] Create `AccountMailer`
  - welcome_email (after registration)
  - email_changed_notification
  - password_changed_notification
- [ ] Create `ShippingMailer`
  - order_shipped (with tracking info)
  - order_delivered
- [ ] Create `MarketingMailer`
  - abandoned_cart_reminder (24hr, 72hr)
  - product_back_in_stock
  - wishlist_item_on_sale
- [ ] Create `MessageMailer` (for messaging system)
  - new_message_notification
  - unread_messages_digest
- [ ] Create email templates in `app/views/` for each mailer
- [ ] Add background jobs for email sending

---

## Priority 4: Inventory Management

### Status: 🔴 Not Started

### Tasks:
- [ ] Create `StockAlert` model
  - product_id
  - threshold (low stock warning level)
  - notified_at
- [ ] Add `reserve_stock` method to Product model
- [ ] Add `release_stock` method for cancelled orders
- [ ] Create background job for daily low-stock checks
- [ ] Add admin notifications for low stock
- [ ] Add seller notifications for their products
- [ ] Prevent checkout if stock insufficient

---

## Priority 5: Product Variants

### Status: 🔴 Not Started

### Tasks:
- [ ] Create `ProductVariant` model
  - product_id
  - name (e.g., "Size", "Color")
  - value (e.g., "Large", "Red")
  - price_modifier (add/subtract from base)
  - stock_quantity
  - sku
- [ ] Update cart to store variant selections
- [ ] Update checkout to handle variants
- [ ] Update product show page with variant selector
- [ ] Update admin product form for variant management

---

## Priority 6: Enhanced Search

### Status: 🔴 Not Started

### Tasks:
- [ ] Add `pg_search` gem to Gemfile
- [ ] Create `PgSearch` multisearch across products
- [ ] Add search autocomplete endpoint
- [ ] Create `search_controller.js` Stimulus controller
- [ ] Add search suggestions dropdown UI
- [ ] Index products on create/update

---

## Priority 7: Abandoned Cart Recovery

### Status: 🔴 Not Started

### Tasks:
- [ ] Create `AbandonedCartJob` background job
- [ ] Schedule job to run hourly (check carts > 24hrs old)
- [ ] Create abandoned cart email template
- [ ] Add `abandoned_cart_email_sent_at` to Cart model
- [ ] Create recovery URL with cart restoration
- [ ] Track conversion from abandoned cart emails

---

## Additional Enhancements (Future)

### Order Tracking
- [ ] Integrate shipping carrier APIs (optional)
- [ ] Add tracking number field to Order
- [ ] Create tracking page for customers
- [ ] Send tracking update emails

### Multi-Currency Support
- [ ] Add currency selection
- [ ] Store prices in base currency
- [ ] Convert on display
- [ ] Update checkout for currency

### Mobile API
- [ ] Create API namespace
- [ ] Add JWT authentication
- [ ] Create API endpoints for products, cart, checkout
- [ ] API documentation with Swagger/OpenAPI

### Real Payment Integration
- [ ] Integrate Paystack (for Ghana/Africa)
- [ ] Integrate Stripe (international)
- [ ] Remove simulated payments from PaymentService
- [ ] Add webhook handlers for payment status

---

## Completed Enhancements ✅

### Session: November 26, 2025
- [x] Share feature for products (`share_controller.js`)
- [x] Guest checkout support (cart & orders without login)
- [x] Phone number field fix (`phone_number` not `phone`)
- [x] OrderMailer method name fix (`confirmation` not `payment_confirmation`)
- [x] Download links for guests (token-based auth, no login required)
- [x] Shipping address validation for physical products
- [x] Guest user creation with valid password

---

## Implementation Notes

### Tech Stack
- **Backend:** Rails 8.0, Ruby 3.3+
- **Frontend:** Hotwire (Turbo + Stimulus), TailwindCSS
- **Database:** PostgreSQL
- **Background Jobs:** Solid Queue
- **File Storage:** Active Storage
- **Authentication:** Devise

### Development Guidelines
- Always run tests before committing
- Each feature should be in its own commit with descriptive message
- Update this document as features are completed
- Follow existing code patterns and conventions

### Testing Commands
```bash
bin/rails test                    # Run all tests
bin/rails test:system             # Run system tests
bundle exec rspec                 # Run RSpec tests
bin/rails db:test:prepare         # Prepare test database