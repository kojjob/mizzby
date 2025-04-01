json.extract! category, :id, :name, :description, :slug, :parent_id, :position, :visible, :icon_name, :icon_color, :created_at, :updated_at
json.url category_url(category, format: :json)
