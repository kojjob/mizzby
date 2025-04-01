module FlashHelper
  # Flash message types available in the application
  FLASH_TYPES = [ :success, :error, :info, :warning ]

  # Map Rails flash keys to our custom types
  FLASH_MAPPING = {
    notice: :success,
    alert: :error
  }

  # Helper to convert Rails default flash types to our custom types
  def flash_message_type(key)
    FLASH_MAPPING[key.to_sym] || key.to_sym
  end

  # Helper to check if the flash message type is valid
  def valid_flash_type?(type)
    FLASH_TYPES.include?(type.to_sym)
  end

  # Add a JavaScript snippet to trigger a flash message
  def js_flash_message(type, message)
    return unless valid_flash_type?(type)

    javascript_tag <<~JS
      document.addEventListener('DOMContentLoaded', () => {
        const flashController = document.getElementById('flash-container')?.
          closest('[data-controller="flash-msg"]')?.
          stimulus_controller;
      #{'  '}
        if (flashController) {
          flashController.show#{type.to_s.capitalize}('#{j message}');
        }
      });
    JS
  end
end
