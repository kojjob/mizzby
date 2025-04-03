class AddOnSaleToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :on_sale, :boolean, default: false, null: false
    add_index :products, :on_sale
  end
end
