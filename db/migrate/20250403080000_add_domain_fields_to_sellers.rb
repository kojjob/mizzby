class AddDomainFieldsToSellers < ActiveRecord::Migration[8.0]
  def change
    add_column :sellers, :store_name, :string
    add_column :sellers, :store_slug, :string
    add_column :sellers, :custom_domain, :string
    add_column :sellers, :domain_verified, :boolean, default: false
    add_column :sellers, :store_settings, :jsonb, default: {}
    
    add_index :sellers, :store_slug, unique: true
    add_index :sellers, :custom_domain, unique: true
  end
end
