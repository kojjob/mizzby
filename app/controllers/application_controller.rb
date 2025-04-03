class ApplicationController < ActionController::Base
  # Include Devise helper methods
  include Devise::Controllers::Helpers
  helper_method :user_session

  # Override user_signed_in? to work with our custom current_user method
  def user_signed_in?
    current_user.present?
  end
  helper_method :user_signed_in?

  # Override current_user to ensure it's always a User object
  def current_user
    user = super
    return nil if user.nil?
    return user unless user.is_a?(Array)

    # If current_user is an Array, try to find the actual user
    if user.first.is_a?(User)
      user.first
    elsif user.first.is_a?(Integer)
      User.find_by(id: user.first)
    else
      nil
    end
  end
  helper_method :current_user
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Basic security headers
  before_action :set_security_headers

  # CanCanCan configuration
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
        flash[:alert] = exception.message
        redirect_to root_path
      end
      format.json { render json: { error: exception.message }, status: :forbidden }
    end
  end

  # Devise configuration
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Store current user location for redirects
  before_action :store_user_location!, if: :storable_location?

  # Check if user needs to complete their profile
  before_action :check_profile_completion, if: :user_signed_in?

  # Check for maintenance mode
  before_action :check_maintenance_mode

  # Helper method for seller access
  def current_seller
    @current_seller ||= current_user.seller if user_signed_in?
  end
  helper_method :current_seller

  # Helper method for admin controllers
  def authenticate_admin!
    unless current_user&.admin? || current_user&.super_admin?
      flash[:error] = "You need administrator privileges to access this area."
      redirect_to root_path and return
    end
  end

  # Helper method for super admin controllers
  def authenticate_super_admin!
    unless current_user&.super_admin?
      flash[:error] = "You need super administrator privileges to access this area."
      redirect_to root_path and return
    end
  end

  # Return to previous page after sign in
  def after_sign_in_path_for(resource_or_scope)
    # Check if user was impersonating
    if session[:admin_id].present? && current_user.id != session[:admin_id]
      # Clear admin_id from session to prevent infinite redirection
      admin_id = session.delete(:admin_id)
      flash[:notice] = "You are now signed in as #{current_user.full_name}."
    end

    # Use stored location or default path
    stored_location_for(resource_or_scope) || super
  end

  # Record user activity
  def record_user_activity(activity_type, title = nil, description = nil, reference = nil)
    return unless current_user

    current_user.user_activities.create(
      activity_type: activity_type,
      title: title || activity_type.humanize,
      description: description,
      reference: reference
    )
  rescue StandardError => e
    Rails.logger.error("Failed to record user activity: #{e.message}")
  end

  def after_sign_in_path_for(resource)
    merge_guest_cart_with_user_cart(resource)
    stored_location_for(resource) || root_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :username ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :profile_picture, :username ])
  end

  # Only store safe locations to return to after sign-in
  def storable_location?
    request.get? &&
    is_navigational_format? &&
    !devise_controller? &&
    !request.xhr? &&
    !request.path.match?(/^\/admin/)
  end

  # Store current location for post-authentication redirect
  def store_user_location!
    # Only store the location if it's a storable location
    store_location_for(:user, request.fullpath) if storable_location?
  end

  # Security headers for better protection
  def set_security_headers
    response.headers["X-Frame-Options"] = "SAMEORIGIN"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
  end

  # Check if user profile is complete
  def check_profile_completion
    return unless user_signed_in? # Make sure a user is signed in
    return if controller_path.start_with?("devise/") || controller_path.start_with?("admin/")
    return if current_user.nil? || current_user.completed_profile? || request.path == edit_user_registration_path

    # Only force profile completion on specific pages
    if force_profile_completion_paths.include?(controller_path)
      flash[:notice] = "Please complete your profile to continue."
      redirect_to edit_user_registration_path
    end
  end

  # Paths where profile completion should be enforced
  def force_profile_completion_paths
    [
      "sellers/registrations",
      "checkout",
      "orders"
    ]
  end

  # Check for maintenance mode
  def check_maintenance_mode
    # Implement this method to check for maintenance mode
    # For example, using a setting in the database or an environment variable
    return unless ENV["MAINTENANCE_MODE"] == "true"

    # Allow super admins to access the site during maintenance
    return if user_signed_in? && current_user&.super_admin?

    # Redirect to maintenance page
    render "shared/maintenance", layout: "maintenance" and return
  end

  # Handle authorization errors (used with Pundit if implemented)
  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore
    flash[:error] = t("#{policy_name}.#{exception.query}", scope: "pundit", default: "You are not authorized to perform this action.")
    redirect_to(request.referrer || root_path)
  end

  private

  def merge_guest_cart_with_user_cart(user)
    guest_cart = Cart.find_by(cart_id: session[:cart_id])

    if guest_cart && guest_cart.cart_items.any?
      user_cart = user.cart || user.create_cart

      # Move items from guest cart to user cart
      guest_cart.cart_items.each do |item|
        existing_item = user_cart.cart_items.find_by(product_id: item.product_id)

        if existing_item
          existing_item.update(quantity: existing_item.quantity + item.quantity)
        else
          item.update(cart_id: user_cart.id)
        end
      end

      # Clean up guest cart
      guest_cart.destroy
      session.delete(:cart_id)
    end
  end
end
