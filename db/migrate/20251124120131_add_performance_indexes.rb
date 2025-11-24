class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    # Add missing composite indexes for frequently queried combinations

    # Orders - performance indexes
    add_index :orders, [ :user_id, :status ], name: 'index_orders_on_user_and_status', if_not_exists: true
    add_index :orders, [ :user_id, :created_at ], name: 'index_orders_on_user_and_created_at', if_not_exists: true
    add_index :orders, [ :payment_status, :created_at ], name: 'index_orders_on_payment_status_and_created_at', if_not_exists: true
    add_index :orders, :payment_id, unique: true, name: 'index_orders_on_payment_id_unique', if_not_exists: true

    # Products - performance indexes
    add_index :products, [ :seller_id, :status ], name: 'index_products_on_seller_and_status', if_not_exists: true
    add_index :products, [ :category_id, :status ], name: 'index_products_on_category_and_status', if_not_exists: true
    add_index :products, [ :featured, :status ], name: 'index_products_on_featured_and_status', if_not_exists: true
    add_index :products, [ :published, :published_at ], name: 'index_products_on_published_and_published_at', if_not_exists: true

    # Reviews - performance indexes
    add_index :reviews, [ :product_id, :published ], name: 'index_reviews_on_product_and_published', if_not_exists: true
    add_index :reviews, [ :product_id, :created_at ], name: 'index_reviews_on_product_and_created_at', if_not_exists: true

    # Cart items - performance indexes
    add_index :cart_items, [ :cart_id, :product_id ], unique: true, name: 'index_cart_items_on_cart_and_product_unique', if_not_exists: true

    # User activities - performance indexes
    add_index :user_activities, [ :user_id, :created_at ], name: 'index_user_activities_on_user_and_created_at', if_not_exists: true
    add_index :user_activities, [ :user_id, :activity_type ], name: 'index_user_activities_on_user_and_activity_type', if_not_exists: true

    # Notifications - performance indexes
    add_index :notifications, [ :user_id, :read_at ], name: 'index_notifications_on_user_and_read_at', if_not_exists: true
    add_index :notifications, [ :user_id, :created_at ], name: 'index_notifications_on_user_and_created_at', if_not_exists: true

    # Download links - performance indexes
    add_index :download_links, [ :user_id, :active ], name: 'index_download_links_on_user_and_active', if_not_exists: true
    add_index :download_links, [ :token ], unique: true, name: 'index_download_links_on_token_unique', if_not_exists: true
    add_index :download_links, [ :expires_at ], name: 'index_download_links_on_expires_at', if_not_exists: true

    # Sellers - performance indexes
    add_index :sellers, [ :verified ], name: 'index_sellers_on_verified', if_not_exists: true
    add_index :sellers, [ :user_id, :verified ], name: 'index_sellers_on_user_and_verified', if_not_exists: true

    # Wishlist items - performance indexes
    add_index :wishlist_items, [ :user_id, :product_id ], unique: true, name: 'index_wishlist_items_on_user_and_product_unique', if_not_exists: true
    add_index :wishlist_items, [ :user_id, :created_at ], name: 'index_wishlist_items_on_user_and_created_at', if_not_exists: true
  end
end
