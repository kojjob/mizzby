module Admin
  class DashboardController < BaseController
    def index
      # Statistics for dashboard
      @total_users = User.count
      @total_products = Product.count rescue 0
      @total_orders = Order.count rescue 0
      @total_revenue = Order.where(status: "completed").sum(:total_amount) rescue 0

      # Recent orders
      @recent_orders = Order.order(created_at: :desc).limit(5) rescue []

      # Recent users
      @recent_users = User.order(created_at: :desc).limit(5)

      # Popular products
      @popular_products = Product.left_joins(:orders)
                                .group(:id)
                                .order("COUNT(orders.id) DESC")
                                .limit(5) rescue []
    end
  end
end
