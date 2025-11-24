class AddColumnsToCart < ActiveRecord::Migration[8.0]
  def change
    add_column :carts, :total_price, :decimal
    add_column :carts, :status, :string
    add_column :carts, :cart_id, :string
  end
end
