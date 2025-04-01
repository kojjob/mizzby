json.extract! download_link, :id, :product_id, :user_id, :token, :expires_at, :download_count, :download_limit, :active, :order_id, :created_at, :updated_at
json.url download_link_url(download_link, format: :json)
