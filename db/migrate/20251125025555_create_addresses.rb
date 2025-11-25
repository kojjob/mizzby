class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :street_address, null: false
      t.string :street_address_2
      t.string :city, null: false
      t.string :state
      t.string :postal_code, null: false
      t.string :country, null: false
      t.string :phone
      t.boolean :default, default: false

      t.timestamps
    end

    add_index :addresses, [ :user_id, :default ]
  end
end
