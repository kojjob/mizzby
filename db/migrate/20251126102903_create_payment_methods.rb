class CreatePaymentMethods < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_methods do |t|
      t.references :user, null: false, foreign_key: true
      t.string :card_type, null: false
      t.string :last_four, null: false
      t.string :cardholder_name, null: false
      t.integer :expiry_month, null: false
      t.integer :expiry_year, null: false
      t.boolean :is_default, default: false
      t.string :token
      t.string :payment_processor, default: 'stripe'
      t.string :nickname
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :payment_methods, [:user_id, :is_default], name: 'index_payment_methods_on_user_and_default'
    add_index :payment_methods, [:user_id, :active], name: 'index_payment_methods_on_user_and_active'
    add_index :payment_methods, :token, unique: true, where: 'token IS NOT NULL'
  end
end
