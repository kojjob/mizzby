# Load application settings into Rails.configuration
Rails.application.config.after_initialize do
  # Skip in database migrations or when the database is not available
  next unless ApplicationSetting.table_exists? rescue false

  # Load settings into Rails configuration
  Rails.configuration.application_settings = ApplicationSetting.get_all

  # Set some convenience methods
  Rails.configuration.site_name = ApplicationSetting.site_name
  Rails.configuration.maintenance_mode = ApplicationSetting.maintenance_mode?

  # Log that settings were loaded
  Rails.logger.info "Application settings loaded: #{Rails.configuration.application_settings.keys.count} settings found"
rescue => e
  Rails.logger.error "Failed to load application settings: #{e.message}"
end
