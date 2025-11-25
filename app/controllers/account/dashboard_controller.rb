class Account::DashboardController < Account::BaseController
  def index
    @recent_orders = current_user.orders.order(created_at: :desc).limit(5)
    @wishlist_count = current_user.wishlist_items.count
  end
end
