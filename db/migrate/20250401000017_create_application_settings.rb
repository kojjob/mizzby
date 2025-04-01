class CreateApplicationSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :application_settings do |t|
      t.string :key, null: false
      t.text :value
      t.string :value_type, default: 'string'
      t.text :description
      t.boolean :editable, default: true
      t.references :updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :application_settings, :key, unique: true

    # Add default settings
    reversible do |dir|
      dir.up do
        execute <<-SQL
          INSERT INTO application_settings (key, value, description, created_at, updated_at) VALUES
          ('site_name', 'Digital Store', 'Name of the website', NOW(), NOW()),
          ('site_description', 'A marketplace for digital and physical products', 'Meta description for the website', NOW(), NOW()),
          ('contact_email', 'contact@example.com', 'Contact email address', NOW(), NOW()),
          ('support_email', 'support@example.com', 'Support email address', NOW(), NOW()),
          ('currency', 'USD', 'Default currency', NOW(), NOW()),
          ('tax_rate', '7.5', 'Default tax rate percentage', NOW(), NOW()),
          ('enable_user_registration', 'true', 'Whether user registration is enabled', NOW(), NOW()),
          ('enable_seller_registration', 'true', 'Whether seller registration is enabled', NOW(), NOW()),
          ('maintenance_mode', 'false', 'Whether the site is in maintenance mode', NOW(), NOW()),
          ('analytics_enabled', 'true', 'Whether analytics are enabled', NOW(), NOW()),
          ('default_commission_rate', '10.0', 'Default commission rate for sellers', NOW(), NOW()),
          ('max_file_upload_size', '10', 'Maximum file upload size in MB', NOW(), NOW()),
          ('allow_guest_checkout', 'false', 'Whether guest checkout is allowed', NOW(), NOW()),
          ('default_download_expiry_days', '7', 'Default expiry days for download links', NOW(), NOW()),
          ('default_download_limit', '5', 'Default download limit for digital products', NOW(), NOW());
        SQL
      end
    end
  end
end
