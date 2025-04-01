class AddSchemaImprovements < ActiveRecord::Migration[8.0]
  def change
    # Add timestamps to relevant fields
    add_column :reviews, :published_at, :datetime
    add_index :reviews, :published_at

    # Add default values for important fields
    change_column_default :reviews, :published, true
    change_column_default :cart_items, :quantity, 1

    # Add non-null constraints to important fields
    change_column_null :reviews, :rating, false
    change_column_null :product_questions, :question, false
    change_column_null :action_items, :title, false

    # Add more specific indexes
    add_index :products, :created_at
    add_index :orders, :created_at
    add_index :user_activities, :activity_type
    add_index :action_items, :completed
    add_index :action_items, :due_date
    add_index :action_items, :priority

    # Add database-level constraints
    execute <<-SQL
      ALTER TABLE reviews
      ADD CONSTRAINT check_rating_range
      CHECK (rating BETWEEN 1 AND 5);
    SQL

    # Add a unique constraint for one seller per user
  end
end
