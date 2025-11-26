class ChangeUserIdNullableInCarts < ActiveRecord::Migration[8.0]
  def change
    # Allow user_id to be null for guest carts
    change_column_null :carts, :user_id, true
  end
end
