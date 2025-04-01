json.extract! wishlist_item, :id, :user_id, :product_id, :notes, :created_at, :updated_at
json.url wishlist_item_url(wishlist_item, format: :json)
