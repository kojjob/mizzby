class AddIndicesForAnalytics < ActiveRecord::Migration[8.0]
  def change
    # Ensure index on product_id in orders table
    add_index :orders, :product_id, if_not_exists: true

    # Add compound index for faster filtering on status and date
    add_index :orders, [ :status, :created_at ], if_not_exists: true

    # Add index on order status
    add_index :orders, :status, if_not_exists: true
  end
end
