json.extract! notification, :id, :user_id, :title, :message, :status, :notification_type, :notifiable_id, :notifiable_type, :read_at, :created_at, :updated_at
json.url notification_url(notification, format: :json)
