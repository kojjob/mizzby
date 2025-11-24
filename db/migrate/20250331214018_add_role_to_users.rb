class AddRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :admin, :boolean
    add_column :users, :super_admin, :boolean
    add_index :users, :super_admin
    add_column :users, :active, :boolean
    add_index :users, :active
  end
end
