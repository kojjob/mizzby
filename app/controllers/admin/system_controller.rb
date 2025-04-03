class Admin::SystemController < Admin::BaseController
  before_action :require_super_admin

  def index
    begin
      # System overview metrics
      @system_stats = {
        rails_version: Rails.version,
        ruby_version: RUBY_VERSION,
        environment: Rails.env,
        database_adapter: ActiveRecord::Base.connection.adapter_name,
        server_time: Time.current,
        uptime: calculate_uptime
      }

      # Database metrics
      @database_stats = {
        total_records: calculate_total_records,
        database_size: calculate_database_size,
        connection_pool: {
          size: ActiveRecord::Base.connection_pool.size,
          connections: ActiveRecord::Base.connection_pool.connections.length,
          active: ActiveRecord::Base.connection_pool.active_connection?
        },
        tables: ActiveRecord::Base.connection.tables.sort
      }

      # Application metrics
      @app_stats = {
        users: User.count,
        products: Product.count,
        orders: Order.count,
        sellers: Seller.count,
        categories: Category.count
      }

      # Recent errors from logs (if available)
      @recent_errors = fetch_recent_errors

      # Recent admin activities (if the model exists)
      @recent_activities = if defined?(AdminActivity)
                             AdminActivity.order(created_at: :desc).limit(20)
                           else
                             []
                           end
    rescue => e
      # Log the error
      Rails.logger.error("Error in system dashboard: #{e.message}\n#{e.backtrace.join("\n")}")

      # Set default values for the view
      @system_stats = { rails_version: Rails.version, ruby_version: RUBY_VERSION, environment: Rails.env, server_time: Time.current }
      @database_stats = { tables: [] }
      @app_stats = {}
      @recent_errors = [{ timestamp: Time.current.to_s, message: "Error loading system information: #{e.message}" }]
      @recent_activities = []

      # Show error message to the user
      flash.now[:alert] = "There was an error loading some system information. Please check the logs for details."
    end
  end

  def logs
    @log_type = params[:type] || 'production'
    @log_content = fetch_log_content(@log_type)
    @log_types = available_log_types

    respond_to do |format|
      format.html
      format.json { render json: { content: @log_content } }
    end
  end

  def cache
    if request.post? && params[:clear_cache]
      Rails.cache.clear
      redirect_to admin_system_cache_path, notice: "Cache cleared successfully"
    end

    @cache_stats = {
      cache_store_type: Rails.cache.class.name,
      cache_entries: estimate_cache_entries
    }
  end

  def jobs
    if defined?(Delayed::Job)
      @pending_jobs = Delayed::Job.where(failed_at: nil).order(created_at: :desc).limit(50)
      @failed_jobs = Delayed::Job.where.not(failed_at: nil).order(failed_at: :desc).limit(50)
    else
      @pending_jobs = []
      @failed_jobs = []
      flash.now[:notice] = "Background job system (Delayed::Job) is not available in this application."
    end
  end

  private

  def require_super_admin
    unless current_user&.super_admin?
      flash[:alert] = "You don't have permission to access this page"
      redirect_to admin_dashboard_path
    end
  end

  def calculate_uptime
    if File.exist?('/proc/uptime')
      uptime_seconds = File.read('/proc/uptime').split.first.to_f
      days = (uptime_seconds / 86400).floor
      hours = ((uptime_seconds % 86400) / 3600).floor
      minutes = ((uptime_seconds % 3600) / 60).floor
      "#{days} days, #{hours} hours, #{minutes} minutes"
    else
      # For non-Linux systems
      "Not available"
    end
  end

  def calculate_total_records
    total = 0
    ActiveRecord::Base.connection.tables.each do |table|
      begin
        # Different adapters return results in different formats
        result = ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM #{table}")
        count = if result.first.is_a?(Hash) && result.first["count"]
                  result.first["count"]
                elsif result.first.is_a?(Array)
                  result.first[0]
                elsif result.first.is_a?(String) || result.first.is_a?(Integer)
                  result.first
                else
                  0
                end
        total += count.to_i
      rescue => e
        Rails.logger.debug("Couldn't count records in table #{table}: #{e.message}")
        # Skip tables that can't be counted
      end
    end
    total
  rescue => e
    Rails.logger.error("Error calculating total records: #{e.message}")
    "Not available"
  end

  def calculate_database_size
    case ActiveRecord::Base.connection.adapter_name
    when 'PostgreSQL'
      result = ActiveRecord::Base.connection.execute(
        "SELECT pg_size_pretty(pg_database_size(current_database()))"
      )
      # Handle different result formats
      if result.first.is_a?(Hash) && result.first["pg_size_pretty"]
        result.first["pg_size_pretty"]
      elsif result.first.is_a?(Array)
        result.first[0]
      else
        "Unknown format"
      end
    when 'MySQL', 'Mysql2'
      result = ActiveRecord::Base.connection.execute(
        "SELECT SUM(data_length + index_length) / 1024 / 1024 FROM information_schema.TABLES WHERE table_schema = '#{ActiveRecord::Base.connection.current_database}'"
      ).first[0]
      "#{result.to_f.round(2)} MB"
    else
      "Not available for this database"
    end
  rescue => e
    Rails.logger.error("Error calculating database size: #{e.message}")
    "Error calculating size"
  end

  def fetch_recent_errors
    errors = []
    log_file = Rails.root.join('log', "#{Rails.env}.log")

    if File.exist?(log_file)
      begin
        # Read the last 1000 lines of the log file
        log_content = `tail -n 1000 #{log_file}`

        # Extract error lines
        error_lines = log_content.split("\n").select do |line|
          line.include?('ERROR') || line.include?('FATAL') || line.include?('Exception')
        end

        # Group and format errors
        errors = error_lines.last(20).map do |line|
          {
            timestamp: line.match(/\[(.*?)\]/)&.captures&.first || 'Unknown',
            message: line.gsub(/\[\d{4}-\d{2}-\d{2}.*?\]/, '').strip
          }
        end
      rescue => e
        errors << { timestamp: Time.current.to_s, message: "Error reading log file: #{e.message}" }
      end
    else
      errors << { timestamp: Time.current.to_s, message: "Log file not found" }
    end

    errors
  end

  def fetch_log_content(log_type)
    log_file = Rails.root.join('log', "#{log_type}.log")

    if File.exist?(log_file)
      begin
        # Read the last 500 lines of the log file
        `tail -n 500 #{log_file}`
      rescue => e
        "Error reading log file: #{e.message}"
      end
    else
      "Log file not found: #{log_file}"
    end
  end

  def available_log_types
    Dir.glob(Rails.root.join('log', '*.log')).map do |file|
      File.basename(file, '.log')
    end
  end

  def estimate_cache_entries
    # This is a rough estimate and depends on the cache store
    if Rails.cache.instance_variable_defined?(:@data)
      Rails.cache.instance_variable_get(:@data).size
    else
      "Not available for this cache store"
    end
  rescue
    "Not available"
  end
end
