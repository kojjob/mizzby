class FixSchemaIssues < ActiveRecord::Migration[8.0]
  def change
    # Fix required fields in orders table
    change_column_null :orders, :payment_details, true
    change_column_null :orders, :notes, true
    change_column_null :orders, :transaction_id, true

    # Add default values for missing fields
    change_column_default :action_items, :priority, 1
    change_column_default :action_items, :completed, false
    change_column_default :download_links, :active, true

    # Fix user_activities reference to be optional
    change_column_null :user_activities, :reference_type, true
    change_column_null :user_activities, :reference_id, true

    # Add missing indexes
    add_index :reviews, :rating
    add_index :download_links, :active
    add_index :reviews, [ :user_id, :product_id ], unique: true, name: 'index_reviews_on_user_id_and_product_id'

    # Fix precision and scale for decimals
    change_column :products, :weight, :decimal, precision: 8, scale: 2
    change_column :sellers, :commission_rate, :decimal, precision: 5, scale: 2
    change_column :sellers, :acceptance_rate, :decimal, precision: 5, scale: 2
  end
end
