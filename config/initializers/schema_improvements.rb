# This initializer adds configuration to improve the database schema behavior

# Configure ActiveRecord to use UUIDs for new models (if you want to switch to UUIDs)
# Rails.application.config.generators do |g|
#   g.orm :active_record, primary_key_type: :uuid
# end

# Enable better query logging in development
if Rails.env.development?
  # Log slow queries
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveRecord::Base.logger.level = Logger::INFO

  # Log queries that take more than 200ms
  ActiveRecord::QueryRecorder.threshold = 200 if defined?(ActiveRecord::QueryRecorder)
end

# Configure schema dump format
ActiveRecord::SchemaDumper.ignore_tables = [ "schema_migrations", "ar_internal_metadata" ]

# Log migrations to keep track of schema changes
unless defined?(Rails::Console) || defined?(Rails::Generators) || Rails.env.test?
  puts "Database schema version: #{ActiveRecord::Migrator.current_version}" if ActiveRecord::Base.connection
end

# Set sensible default SQL mode
if ActiveRecord::Base.connection.adapter_name == "Mysql2"
  sql_mode = "STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
  ActiveRecord::Base.connection.execute("SET SQL_MODE='#{sql_mode}'")
end
