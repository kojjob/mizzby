class AddPreferencesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :preferences, :jsonb, default: {}, null: false
    add_column :users, :country, :string
    add_column :users, :phone_number, :string
    add_column :users, :timezone, :string
    add_column :users, :bio, :text
    add_column :users, :last_activity_at, :datetime

    add_index :users, :preferences, using: :gin
    add_index :users, :country
  end
end
