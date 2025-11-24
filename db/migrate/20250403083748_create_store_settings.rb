class CreateStoreSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :store_settings do |t|
      t.references :store, null: false, foreign_key: true
      t.string :key
      t.text :value

      t.timestamps
    end
  end
end
