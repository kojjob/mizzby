module ApplicationHelper
  # Helper method to check if the current user is a seller
  def current_user_is_seller?
    current_user&.seller.present?
  end

  # Helper method to check if the current user is an admin
  def current_user_is_admin?
    current_user&.admin?
  end

  # Helper method to check if the current user is a super admin
  def current_user_is_super_admin?
    current_user&.super_admin?
  end

  # Helper to format dates consistently
  def format_date(date, format = :default)
    return unless date

    case format
    when :short
      date.strftime("%b %d, %Y")
    when :long
      date.strftime("%B %d, %Y at %I:%M %p")
    when :time
      date.strftime("%I:%M %p")
    when :default
      date.strftime("%Y-%m-%d")
    end
  end

  # Helper to format prices consistently
  def format_price(price, currency = "USD")
    number_to_currency(price, unit: currency_symbol(currency), precision: 2)
  end

  # Helper to display appropriate currency symbol
  def currency_symbol(currency)
    case currency.to_s.upcase
    when "USD"
      "$"
    when "EUR"
      "€"
    when "GBP"
      "£"
    when "GHS"
      "₵"
    when "NGN"
      "₦"
    else
      currency.to_s
    end
  end

  # Helper to generate CSS classes for order status
  def order_status_color(status)
    case status&.to_s&.downcase
    when "pending"
      "bg-yellow-100 text-yellow-800"
    when "processing"
      "bg-blue-100 text-blue-800"
    when "paid"
      "bg-green-100 text-green-800"
    when "completed"
      "bg-indigo-100 text-indigo-800"
    when "cancelled"
      "bg-red-100 text-red-800"
    when "refunded"
      "bg-purple-100 text-purple-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end

  # Helper to truncate text with ellipsis
  def truncate_text(text, length = 100, omission = "...")
    truncate(text, length: length, omission: omission)
  end

  # Helper to determine if a menu item is active
  def active_menu_item(controller_name, action_name = nil)
    is_current_controller = controller.controller_name == controller_name.to_s
    is_current_action = action_name.nil? || controller.action_name == action_name.to_s

    is_current_controller && is_current_action ? "active" : ""
  end

  # Helper to generate page titles
  def page_title(title = nil)
    base_title = "Digital Store"
    title.present? ? "#{title} | #{base_title}" : base_title
  end

  # Helper for meta descriptions
  def meta_description(description = nil)
    default_description = "The complete platform for selling digital products online. Secure delivery, seamless payments, and powerful analytics to grow your business."
    description.present? ? description : default_description
  end

  # Add these methods to your ApplicationHelper
  def category_color_class(category)
    # Create a consistent color based on the category name
    colors = [
      "bg-red-100 text-red-600",
      "bg-blue-100 text-blue-600",
      "bg-green-100 text-green-600",
      "bg-yellow-100 text-yellow-600",
      "bg-purple-100 text-purple-600",
      "bg-pink-100 text-pink-600",
      "bg-indigo-100 text-indigo-600",
      "bg-teal-100 text-teal-600"
    ]
  
    # Use the category ID or name to pick a consistent color
    index = category.id.nil? ? category.name.sum : category.id
    colors[index % colors.length]
  end

  def category_icon(category)
    # Map category names to appropriate icons
    icon_map = {
      "books" => '<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" /></svg>',
    
      "music" => '<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3" /></svg>',
    
      "software" => '<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" /></svg>',
    
      "courses" => '<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" /></svg>',
    
      "art" => '<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>',
    
      "templates" => '<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 5a1 1 0 011-1h14a1 1 0 011 1v2a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 13a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H5a1 1 0 01-1-1v-6zM16 13a1 1 0 011-1h2a1 1 0 011 1v6a1 1 0 01-1 1h-2a1 1 0 01-1-1v-6z" /></svg>',
    
      "photography" => '<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" /></svg>'
    }
  
    # Default icon if no match is found
    default_icon = '<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" /></svg>'
  
    # Try to find a match (case insensitive)
    category_name = category.name.downcase
    icon_map.each do |key, icon|
      return icon.html_safe if category_name.include?(key) || key.include?(category_name)
    end
  
    # Return default icon if no match
    default_icon.html_safe
  end
end
