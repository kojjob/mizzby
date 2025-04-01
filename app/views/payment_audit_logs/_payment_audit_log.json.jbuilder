json.extract! payment_audit_log, :id, :user_id, :order_id, :event_type, :payment_processor, :amount, :transaction_id, :metadata, :ip_address, :user_agent, :created_at, :updated_at
json.url payment_audit_log_url(payment_audit_log, format: :json)
