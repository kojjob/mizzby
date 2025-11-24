json.extract! user_activity, :id, :user_id, :activity_type, :title, :description, :icon, :color, :reference_id, :reference_type, :created_at, :updated_at
json.url user_activity_url(user_activity, format: :json)
