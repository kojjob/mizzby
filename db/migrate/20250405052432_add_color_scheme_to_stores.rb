class AddColorSchemeToStores < ActiveRecord::Migration[8.0]
  def change
    add_column :stores, :color_scheme, :string, default: 'light'
  end
end
