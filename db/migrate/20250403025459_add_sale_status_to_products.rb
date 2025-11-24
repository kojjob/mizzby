class AddSaleStatusToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :sale_status, :integer, default: 0
    add_index :products, :sale_status
  end
end
