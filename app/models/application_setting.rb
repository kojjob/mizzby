class ApplicationSetting < ApplicationRecord
  belongs_to :updated_by, class_name: "User", optional: true

  # Validations
  validates :key, presence: true, uniqueness: true

  # Class methods for easy access to settings
  class << self
    def get(key)
      Rails.cache.fetch("application_setting:#{key}", expires_in: 1.hour) do
        find_by(key: key.to_s)&.typed_value
      end
    end

    def set(key, value, user = nil)
      setting = find_or_initialize_by(key: key.to_s)
      setting.value = value.to_s
      setting.updated_by = user if user

      # Clear cache if the save was successful
      Rails.cache.delete("application_setting:#{key}") if setting.save

      setting
    end

    def get_all
      Rails.cache.fetch("application_settings:all", expires_in: 1.hour) do
        all.each_with_object({}) do |setting, hash|
          hash[setting.key.to_sym] = setting.typed_value
        end
      end
    end

    def reload
      Rails.cache.delete_matched("application_setting:*")
      Rails.cache.delete("application_settings:all")
      true
    end

    # Common settings
    def site_name
      get(:site_name) || "Digital Store"
    end

    def maintenance_mode?
      get(:maintenance_mode).to_s == "true"
    end

    def analytics_enabled?
      get(:analytics_enabled).to_s == "true"
    end

    def default_currency
      get(:currency) || "USD"
    end

    def default_commission_rate
      get(:default_commission_rate).to_f
    end
  end

  # Convert the string value to appropriate type
  def typed_value
    case value_type
    when "integer"
      value.to_i
    when "float"
      value.to_f
    when "boolean"
      value == "true"
    when "json"
      JSON.parse(value)
    else
      value
    end
  rescue
    value
  end
end
