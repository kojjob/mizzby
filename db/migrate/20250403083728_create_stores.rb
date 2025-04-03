class CreateStores < ActiveRecord::Migration[8.0]
  def change
    create_table :stores do |t|
      t.references :seller, null: false, foreign_key: true
      t.string :name
      t.string :slug
      t.text :description

      t.timestamps
    end
    add_index :stores, :slug, unique: true
  end
end
