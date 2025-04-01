class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :status, default: "pending", null: false
      t.decimal :total_amount, precision: 10, scale: 2
      t.decimal :shipping_cost, precision: 10, scale: 2
      t.decimal :discount, precision: 10, scale: 2
      t.string :payment_processor, default: "default_processor"
      t.string :payment_method, default: "credit_card"
      t.string :transaction_id, null: false
      t.string :payment_id, null: false
      t.string :payment_status, default: "pending"
      t.text :payment_details, null: false
      t.text :notes, null: false

      t.timestamps
    end
    add_index :orders, :status
    add_index :orders, :total_amount
    add_index :orders, :shipping_cost
    add_index :orders, :discount
  end
end
