class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin

  def index
    redirect_to admin_root_path
  end

  def dashboard
    # Redirect to the dashboard index action in the Admin namespace
    redirect_to admin_root_path
  end

  private

  def authorize_admin
    unless current_user&.admin? || current_user&.super_admin?
      flash[:error] = "You don't have permission to access the admin area."
      redirect_to root_path
    end
  end
end
