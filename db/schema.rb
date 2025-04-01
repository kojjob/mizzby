# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_04_01_165507) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "description"
    t.integer "priority", default: 1
    t.date "due_date"
    t.boolean "completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["completed"], name: "index_action_items_on_completed"
    t.index ["due_date"], name: "index_action_items_on_due_date"
    t.index ["priority"], name: "index_action_items_on_priority"
    t.index ["user_id"], name: "index_action_items_on_user_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "application_settings", force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.string "value_type", default: "string"
    t.text "description"
    t.boolean "editable", default: true
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_application_settings_on_key", unique: true
    t.index ["updated_by_id"], name: "index_application_settings_on_updated_by_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "slug"
    t.bigint "parent_id"
    t.integer "position"
    t.boolean "visible"
    t.string "icon_name"
    t.string "icon_color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "download_links", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "user_id", null: false
    t.string "token"
    t.datetime "expires_at"
    t.integer "download_count"
    t.integer "download_limit"
    t.boolean "active", default: true
    t.bigint "order_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_download_links_on_active"
    t.index ["order_id"], name: "index_download_links_on_order_id"
    t.index ["product_id"], name: "index_download_links_on_product_id"
    t.index ["user_id"], name: "index_download_links_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "message"
    t.integer "status"
    t.integer "notification_type"
    t.string "notifiable_type", null: false
    t.bigint "notifiable_id", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.string "status", default: "pending", null: false
    t.decimal "total_amount", precision: 10, scale: 2
    t.decimal "shipping_cost", precision: 10, scale: 2
    t.decimal "discount", precision: 10, scale: 2
    t.string "payment_processor", default: "default_processor"
    t.string "payment_method", default: "credit_card"
    t.string "transaction_id"
    t.string "payment_id", null: false
    t.string "payment_status", default: "pending"
    t.text "payment_details"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["discount"], name: "index_orders_on_discount"
    t.index ["product_id"], name: "index_orders_on_product_id"
    t.index ["shipping_cost"], name: "index_orders_on_shipping_cost"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["total_amount"], name: "index_orders_on_total_amount"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payment_audit_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "order_id", null: false
    t.string "event_type"
    t.string "payment_processor"
    t.decimal "amount"
    t.string "transaction_id"
    t.text "metadata"
    t.inet "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payment_audit_logs_on_order_id"
    t.index ["user_id"], name: "index_payment_audit_logs_on_user_id"
  end

  create_table "product_images", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.integer "position"
    t.string "alt_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_images_on_product_id"
  end

  create_table "product_questions", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "user_id", null: false
    t.string "asked_by"
    t.text "question", null: false
    t.text "answer"
    t.string "answered_by"
    t.datetime "answered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_questions_on_product_id"
    t.index ["user_id"], name: "index_product_questions_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.decimal "price", precision: 10, scale: 2
    t.decimal "discounted_price", precision: 10, scale: 2
    t.string "image_url", default: [], array: true
    t.string "thumbnail_url", default: [], array: true
    t.string "video_url", default: [], array: true
    t.string "color", default: [], array: true
    t.integer "stock_quantity", default: 0
    t.string "sku", null: false
    t.string "barcode", null: false
    t.string "manufacturer"
    t.decimal "weight", precision: 8, scale: 2
    t.string "dimensions"
    t.string "condition", default: "new", null: false
    t.string "brand", null: false
    t.boolean "featured", default: false
    t.string "tags", default: [], array: true
    t.string "currency"
    t.string "country_of_origin", null: false
    t.boolean "available_in_ghana", default: false
    t.boolean "available_in_nigeria", default: false
    t.string "shipping_method", default: "standard"
    t.string "shipping_cost", default: "0.00"
    t.string "shipping_provider", default: "default_provider"
    t.string "shipping_duration", default: "3-5 days"
    t.string "shipping_weight", default: "0.00"
    t.string "shipping_time", default: "standard"
    t.bigint "category_id", null: false
    t.bigint "seller_id", null: false
    t.boolean "published", default: false
    t.datetime "published_at"
    t.datetime "unpublished_at"
    t.string "meta_keywords", default: [], array: true
    t.string "meta_title", null: false
    t.text "meta_description", null: false
    t.boolean "is_digital", default: false
    t.string "status", default: "active", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active"
    t.index ["available_in_ghana"], name: "index_products_on_available_in_ghana"
    t.index ["available_in_nigeria"], name: "index_products_on_available_in_nigeria"
    t.index ["barcode"], name: "index_products_on_barcode", unique: true
    t.index ["brand"], name: "index_products_on_brand"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["condition"], name: "index_products_on_condition"
    t.index ["country_of_origin"], name: "index_products_on_country_of_origin"
    t.index ["created_at"], name: "index_products_on_created_at"
    t.index ["currency"], name: "index_products_on_currency"
    t.index ["description"], name: "index_products_on_description"
    t.index ["dimensions"], name: "index_products_on_dimensions"
    t.index ["discounted_price"], name: "index_products_on_discounted_price"
    t.index ["featured"], name: "index_products_on_featured"
    t.index ["is_digital"], name: "index_products_on_is_digital"
    t.index ["meta_description"], name: "index_products_on_meta_description"
    t.index ["meta_keywords"], name: "index_products_on_meta_keywords", using: :gin
    t.index ["meta_title"], name: "index_products_on_meta_title"
    t.index ["name"], name: "index_products_on_name"
    t.index ["price"], name: "index_products_on_price"
    t.index ["published"], name: "index_products_on_published"
    t.index ["published_at"], name: "index_products_on_published_at"
    t.index ["seller_id"], name: "index_products_on_seller_id"
    t.index ["shipping_method"], name: "index_products_on_shipping_method"
    t.index ["shipping_time"], name: "index_products_on_shipping_time"
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.index ["status"], name: "index_products_on_status"
    t.index ["stock_quantity"], name: "index_products_on_stock_quantity"
    t.index ["tags"], name: "index_products_on_tags", using: :gin
    t.index ["weight"], name: "index_products_on_weight"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.integer "rating", null: false
    t.text "content"
    t.boolean "published", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "published_at"
    t.index ["product_id"], name: "index_reviews_on_product_id"
    t.index ["published_at"], name: "index_reviews_on_published_at"
    t.index ["rating"], name: "index_reviews_on_rating"
    t.index ["user_id", "product_id"], name: "index_reviews_on_user_id_and_product_id", unique: true
    t.index ["user_id"], name: "index_reviews_on_user_id"
    t.check_constraint "rating >= 1 AND rating <= 5", name: "check_rating_range"
  end

  create_table "sellers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "business_name"
    t.text "description"
    t.string "location"
    t.string "country"
    t.string "phone_number"
    t.boolean "verified"
    t.decimal "commission_rate", precision: 5, scale: 2
    t.decimal "acceptance_rate", precision: 5, scale: 2
    t.integer "average_response_time"
    t.text "bank_account_details"
    t.text "mobile_money_details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sellers_on_user_id"
  end

  create_table "user_activities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "activity_type"
    t.string "title"
    t.text "description"
    t.string "icon"
    t.string "color"
    t.string "reference_type"
    t.bigint "reference_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_type"], name: "index_user_activities_on_activity_type"
    t.index ["reference_type", "reference_id"], name: "index_user_activities_on_reference"
    t.index ["user_id"], name: "index_user_activities_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "username", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin"
    t.boolean "super_admin"
    t.boolean "active"
    t.string "profile_picture"
    t.jsonb "preferences", default: {}, null: false
    t.string "country"
    t.string "phone_number"
    t.string "timezone"
    t.text "bio"
    t.datetime "last_activity_at"
    t.index ["active"], name: "index_users_on_active"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["country"], name: "index_users_on_country"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["preferences"], name: "index_users_on_preferences", using: :gin
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["super_admin"], name: "index_users_on_super_admin"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "wishlist_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_wishlist_items_on_product_id"
    t.index ["user_id"], name: "index_wishlist_items_on_user_id"
  end

  add_foreign_key "action_items", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "application_settings", "users", column: "updated_by_id"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "products"
  add_foreign_key "carts", "users"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "download_links", "orders"
  add_foreign_key "download_links", "products"
  add_foreign_key "download_links", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "orders", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "payment_audit_logs", "orders"
  add_foreign_key "payment_audit_logs", "users"
  add_foreign_key "product_images", "products"
  add_foreign_key "product_questions", "products"
  add_foreign_key "product_questions", "users"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "sellers"
  add_foreign_key "reviews", "products"
  add_foreign_key "reviews", "users"
  add_foreign_key "sellers", "users"
  add_foreign_key "user_activities", "users"
  add_foreign_key "wishlist_items", "products"
  add_foreign_key "wishlist_items", "users"
end
