class CreateDownloadLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :download_links do |t|
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :token
      t.datetime :expires_at
      t.integer :download_count
      t.integer :download_limit
      t.boolean :active
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
