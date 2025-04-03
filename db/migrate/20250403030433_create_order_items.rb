class CreateOrderItems < ActiveRecord::Migration[8.0]
  def change

    create_table :order_items do |t|
      # References to associated models
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      # Quantity of the product in this order item
      t.integer :quantity, default: 1, null: false
      # Status of the order item
      t.integer :status, default: 0, null: false # 0: pending, 1: shipped, 2: delivered, 3: returned
      # Shipping information
      t.string :shipping_address, null: false
      t.string :shipping_method, null: false
      t.decimal :shipping_cost, precision: 10, scale: 2, default: 0.0
      # Payment information
      t.string :payment_method, null: false
      t.string :payment_status, default: "pending" # pending, completed, failed
      # Tax information
      t.decimal :tax_rate, precision: 5, scale: 2, default: 0.0
      t.decimal :tax_amount, precision: 10, scale: 2, default: 0.0
      # Discount information
      t.decimal :discount_rate, precision: 5, scale: 2, default: 0.0
      t.decimal :discount_amount, precision: 10, scale: 2, default: 0.0
      # Product details
      t.string :product_name, null: false
      t.string :product_sku, null: false
      t.string :product_image_url
      t.text   :product_description

      # Pricing information
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.decimal :total_price, precision: 10, scale: 2, null: false

      # Optional: Additional attributes
      t.text :customization_notes
      t.boolean :is_gift, default: false

      t.timestamps
    end
    # Add indexes for faster lookups
    add_index :order_items, [:order_id, :product_id], unique: true
    add_index :order_items, :status
    add_index :order_items, :payment_status
    add_index :order_items, :shipping_method
    add_index :order_items, :created_at
  end
end
