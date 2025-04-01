module Admin
  class SettingsController < BaseController
    before_action :authorize_super_admin

    def index
      # Load application settings
      @settings = ApplicationSetting.get_all

      # Get statistics for display
      @user_count = User.count
      @product_count = Product.count
      @order_count = Order.count
      @seller_count = Seller.count
    end

    def update
      # Update settings
      params[:settings].each do |key, value|
        ApplicationSetting.set(key, value)
      end

      # Refresh settings in the application
      ApplicationSetting.reload

      flash[:success] = "Settings have been updated successfully."
      redirect_to admin_settings_path
    end

    def security
      # Security-related settings and information
      @failed_login_attempts = FailedLoginAttempt.order(created_at: :desc)
                                               .limit(25)

      @payment_audit_logs = PaymentAuditLog.order(created_at: :desc)
                                          .limit(25)

      @user_activities = UserActivity.order(created_at: :desc)
                                    .limit(25)
    end

    def maintenance
      # System maintenance operations
    end

    def backup
      # Database backup functionality
      BackupJob.perform_later(current_user.id)

      flash[:success] = "Backup process started. You will be notified when it's complete."
      redirect_to admin_settings_path
    end

    def logs
      # Application logs viewer
      @log_files = {
        production: Rails.root.join("log", "production.log"),
        development: Rails.root.join("log", "development.log")
      }

      @selected_log = params[:log_file] || "production"
      @log_content = []

      if @log_files[@selected_log.to_sym] && File.exist?(@log_files[@selected_log.to_sym])
        # Read the last 100 lines of the log file
        @log_content = `tail -n 100 #{@log_files[@selected_log.to_sym]}`.split("\n")
      end
    end

    def clear_cache
      # Clear Rails cache
      Rails.cache.clear

      flash[:success] = "Application cache has been cleared successfully."
      redirect_to admin_settings_path
    end

    def restart_application
      # This would normally be handled through a deployment tool like Kamal
      # For demo purposes, we just simulate a restart
      AppRestartJob.perform_later(current_user.id)

      flash[:success] = "Application restart initiated. This may take a few moments."
      redirect_to admin_settings_path
    end
  end
end

# Placeholder model for application settings
class ApplicationSetting
  class << self
    def get_all
      {
        site_name: "Digital Store",
        site_description: "A marketplace for digital and physical products",
        contact_email: "contact@example.com",
        support_email: "support@example.com",
        currency: "USD",
        tax_rate: "7.5",
        enable_user_registration: "true",
        enable_seller_registration: "true",
        maintenance_mode: "false",
        analytics_enabled: "true",
        default_commission_rate: "10.0",
        max_file_upload_size: "10",
        allow_guest_checkout: "false",
        default_download_expiry_days: "7",
        default_download_limit: "5",
        social_login_enabled: "true",
        require_email_confirmation: "true"
      }
    end

    def get(key)
      # In a real application, this would fetch from database or Redis
      get_all[key.to_sym]
    end

    def set(key, value)
      # In a real application, this would save to database or Redis
      Rails.logger.info("Setting #{key} to #{value}")
      true
    end

    def reload
      # In a real application, this would reload settings from database
      Rails.logger.info("Reloading application settings")
      true
    end
  end
end

# Placeholder models for demo
class FailedLoginAttempt
  def self.order(*)
    []
  end
end

class BackupJob < ActiveJob::Base
  def self.perform_later(*)
    true
  end
end

class AppRestartJob < ActiveJob::Base
  def self.perform_later(*)
    true
  end
end
