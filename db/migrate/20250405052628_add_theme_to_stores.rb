class AddThemeToStores < ActiveRecord::Migration[8.0]
  def change
    add_column :stores, :theme, :string, default: 'default'
  end
end
