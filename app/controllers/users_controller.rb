class UsersController < ApplicationController
  before_action :authenticate_user!

  def dashboard
    # Add your dashboard logic here
    @recent_orders = current_user.orders.order(created_at: :desc).limit(5)
    @wishlist_items = current_user.wishlist_items.includes(:product).limit(4)
  end

  def profile
    # Add your profile logic here
    @user = current_user
  end

  # ... other actions ...
end
