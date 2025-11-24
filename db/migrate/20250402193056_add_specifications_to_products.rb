class AddSpecificationsToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :specifications, :text, array: true, default: []
  end
end
