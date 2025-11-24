module Admin
  class BaseController < ApplicationController
    # layout "admin/application"
    # layout 'admin'


    before_action :authenticate_user!
    before_action :authorize_admin

    # Helper method to get the current admin policy
    def admin_policy
      @admin_policy ||= AdminPolicy.new(current_user)
    end

    # Make admin_policy available to views
    helper_method :admin_policy

    protected

    def authorize_admin
      unless admin_policy.admin?
        flash[:error] = "You don't have permission to access the admin area."
        redirect_to root_path
      end
    end

    def authorize_super_admin
      unless admin_policy.super_admin?
        flash[:error] = "This action requires super admin privileges."
        redirect_to admin_root_path
      end
    end

    def authorize_action(action)
      method_name = "can_#{action}?"
      unless admin_policy.respond_to?(method_name) && admin_policy.send(method_name)
        flash[:error] = "You don't have permission to perform this action."
        redirect_back(fallback_location: admin_root_path)
      end
    end
  end
end
