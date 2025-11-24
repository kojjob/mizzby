class AddPublishedToStores < ActiveRecord::Migration[8.0]
  def change
    add_column :stores, :published, :boolean, default: true
  end
end
