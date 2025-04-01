class CreateSellers < ActiveRecord::Migration[8.0]
  def change
    create_table :sellers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :business_name
      t.text :description
      t.string :location
      t.string :country
      t.string :phone_number
      t.boolean :verified
      t.decimal :commission_rate
      t.decimal :acceptance_rate
      t.integer :average_response_time
      t.text :bank_account_details
      t.text :mobile_money_details

      t.timestamps
    end
  end
end
