module UsersHelper
  def user_avatar(user, size = 'w-8 h-8')
    if user.nil?
      # Default avatar for non-logged in users
      content_tag :div, class: "#{size} rounded-full bg-indigo-100 flex items-center justify-center text-indigo-600" do
        content_tag :svg, xmlns: "http://www.w3.org/2000/svg", class: "h-5 w-5", viewBox: "0 0 20 20", fill: "currentColor" do
          content_tag :path, nil, fill_rule: "evenodd", d: "M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z", clip_rule: "evenodd"
        end
      end
    elsif user.profile_picture.present?
      # User has a profile picture
      image_tag user.profile_picture, class: "#{size} rounded-full object-cover"
    else
      # User has no profile picture, show initials
      content_tag :div, class: "#{size} rounded-full bg-indigo-100 flex items-center justify-center text-indigo-600 font-semibold" do
        if user.first_name.present? && user.last_name.present?
          "#{user.first_name.first.upcase}#{user.last_name.first.upcase}"
        else
          # Fallback if no name
          user.email.first.upcase
        end
      end
    end
  end

  def user_role_badge_classes(user)
    if user.nil?
      "bg-gray-100 text-gray-800"
    elsif user.super_admin?
      "bg-red-100 text-red-800"
    elsif user.admin?
      "bg-blue-100 text-blue-800"
    elsif user.seller.present?
      "bg-green-100 text-green-800"
    else
      "bg-indigo-100 text-indigo-800"
    end
  end

  def user_role_text(user)
    if user.nil?
      "Guest"
    elsif user.super_admin?
      "Super Admin"
    elsif user.admin?
      "Admin"
    elsif user.seller.present?
      "Seller"
    else
      "Customer"
    end
  end
end
