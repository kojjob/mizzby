class CreateStoreCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :store_categories do |t|
      t.references :store, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.integer :position

      t.timestamps
    end
  end
end
