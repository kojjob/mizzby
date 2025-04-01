json.extract! order, :id, :user_id, :product_id, :status, :total_amount, :payment_processor, :payment_id, :payment_status, :payment_details, :notes, :created_at, :updated_at
json.url order_url(order, format: :json)
