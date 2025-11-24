class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.decimal :discounted_price, precision: 10, scale: 2
      t.string :image_url, array: true, default: []
      t.string :thumbnail_url, array: true, default: []
      t.string :video_url, array: true, default: []
      t.string :color, array: true, default: []
      t.integer :stock_quantity, default: 0
      t.string :sku, null: false
      t.string :barcode, null: false
      t.string :manufacturer
      t.decimal :weight
      t.string :dimensions
      t.string :condition, default: "new", null: false
      t.string :brand, null: false
      t.boolean :featured, default: false
      t.string :tags, array: true, default: []
      t.string :currency
      t.string :country_of_origin, null: false
      t.boolean :available_in_ghana, default: false
      t.boolean :available_in_nigeria, default: false
      t.string :shipping_method, default: "standard"
      t.string :shipping_cost, default: "0.00"
      t.string :shipping_provider, default: "default_provider"
      t.string :shipping_duration, default: "3-5 days"
      t.string :shipping_weight, default: "0.00"
      t.string :shipping_time, default: "standard"
      t.references :category, null: false, foreign_key: true
      t.references :seller, null: false, foreign_key: true
      t.boolean :published, default: false
      t.datetime :published_at, null: true
      t.datetime :unpublished_at, null: true
      t.string :meta_keywords, array: true, default: []
      t.string :meta_title, null: false
      t.text :meta_description, null: false
      t.boolean :is_digital, default: false
      t.string :status, default: "active", null: false
      t.string :slug, null: false

      t.timestamps
    end
    add_index :products, :name
    add_index :products, :description
    add_index :products, :price
    add_index :products, :discounted_price
    add_index :products, :stock_quantity
    add_index :products, :sku, unique: true
    add_index :products, :barcode, unique: true
    add_index :products, :weight
    add_index :products, :dimensions
    add_index :products, :condition
    add_index :products, :brand
    add_index :products, :featured
    add_index :products, :currency
    add_index :products, :country_of_origin
    add_index :products, :available_in_ghana
    add_index :products, :available_in_nigeria
    add_index :products, :shipping_time
    add_index :products, :published
    add_index :products, :published_at
    add_index :products, :meta_title
    add_index :products, :meta_description
    add_index :products, :is_digital
    add_index :products, :status
    add_index :products, :slug, unique: true
    add_index :products, :tags, using: :gin
    add_index :products, :meta_keywords, using: :gin
    add_index :products, :shipping_method
  end
end
