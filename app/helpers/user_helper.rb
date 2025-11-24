module UserHelper
  # Get user avatar initials (first letters of first and last name)
  def user_initials(user)
    return "GU" unless user.present?

    first = user.first_name.present? ? user.first_name.first.upcase : ""
    last = user.last_name.present? ? user.last_name.first.upcase : ""

    if first.present? || last.present?
      "#{first}#{last}"
    else
      # Fallback to email initial if no name
      user.email.first.upcase
    end
  end

  # Returns badge classes for user role
  def user_role_badge_classes(user)
    return "" unless user.present?

    if user.super_admin?
      "bg-red-100 text-red-800"
    elsif user.admin?
      "bg-blue-100 text-blue-800"
    elsif user.seller.present?
      "bg-green-100 text-green-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end

  # Returns user role text
  def user_role_text(user)
    return "Guest" unless user.present?

    if user.super_admin?
      "Super Admin"
    elsif user.admin?
      "Admin"
    elsif user.seller.present?
      "Seller"
    else
      "Customer"
    end
  end

  # Returns appropriate avatar for user
  def user_avatar(user, size_class = "w-10 h-10")
    return content_tag :div, "GU", class: "#{size_class} rounded-full bg-gray-100 flex items-center justify-center text-gray-600 font-semibold" unless user.present?

    if user.profile_picture.present?
      image_tag user.profile_picture, class: "#{size_class} rounded-full object-cover"
    else
      content_tag :div, user_initials(user), class: "#{size_class} rounded-full bg-indigo-100 flex items-center justify-center text-indigo-600 font-semibold"
    end
  end

  # Check if user should see admin options
  def show_admin_options?(user)
    user.present? && (user.admin? || user.super_admin?)
  end

  # Check if user should see seller options
  def show_seller_options?(user)
    user.present? && user.seller.present?
  end

  # Check if user should see super admin options
  def show_super_admin_options?(user)
    user.present? && user.super_admin?
  end

  # Get list of navigation options based on user role
  def user_navigation_options(user)
    return [] unless user.present?

    options = [
      { name: "My Profile", path: "/account/profile", icon: "user" },
      { name: "Orders", path: "/account/orders", icon: "shopping-bag" },
      { name: "Downloads", path: "/account/downloads", icon: "download" },
      { name: "Wishlist", path: "/account/wishlist", icon: "heart" }
    ]

    if show_seller_options?(user)
      options += [
        { name: "My Products", path: "/seller/products", icon: "box" },
        { name: "Sales Analytics", path: "/seller/sales", icon: "chart" },
        { name: "Earnings", path: "/seller/earnings", icon: "dollar" }
      ]
    end

    if show_admin_options?(user)
      options += [
        { name: "Admin Dashboard", path: "/admin/dashboard", icon: "dashboard" },
        { name: "Users", path: "/admin/users", icon: "users" },
        { name: "Products", path: "/admin/products", icon: "database" },
        { name: "Categories", path: "/admin/categories", icon: "folder" }
      ]
    end

    if show_super_admin_options?(user)
      options += [
        { name: "System Settings", path: "/admin/system", icon: "settings" },
        { name: "Security", path: "/admin/security", icon: "shield" },
        { name: "Audit Logs", path: "/admin/audit-logs", icon: "clipboard" }
      ]
    end

    options
  end
end
