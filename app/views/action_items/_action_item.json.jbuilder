json.extract! action_item, :id, :user_id, :title, :description, :priority, :due_date, :completed, :created_at, :updated_at
json.url action_item_url(action_item, format: :json)
