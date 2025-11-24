module Admin
  class DashboardController < BaseController
    def index
    @users_count = User.count
    @orders_count = Order.count
    @products_count = Product.count

    # Only show these links to super admins
    if current_user.super_admin?
      @all_models = [
        { name: "Users", path: admin_users_path, count: User.count },
        { name: "Products", path: admin_products_path, count: Product.count },
        { name: "Orders", path: admin_orders_path, count: Order.count },
        { name: "Categories", path: admin_categories_path, count: Category.count },
        { name: "Sellers", path: admin_sellers_path, count: Seller.count },
        { name: "Reviews", path: admin_reviews_path, count: Review.count },
        { name: "Carts", path: admin_carts_path, count: Cart.count },
        { name: "Cart Items", path: admin_cart_items_path, count: CartItem.count },
        { name: "Download Links", path: admin_download_links_path, count: DownloadLink.count },
        { name: "Product Images", path: admin_product_images_path, count: ProductImage.count },
        { name: "Product Questions", path: admin_product_questions_path, count: ProductQuestion.count },
        { name: "Payment Audit Logs", path: admin_payment_audit_logs_path, count: PaymentAuditLog.count },
        { name: "Notifications", path: admin_notifications_path, count: Notification.count },
        { name: "Wishlist Items", path: admin_wishlist_items_path, count: WishlistItem.count },
        { name: "User Activities", path: admin_user_activities_path, count: UserActivity.count },
        { name: "Action Items", path: admin_action_items_path, count: ActionItem.count }
      ]
    end
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
      @popular_products = Product.joins(:orders)
                                    .select("products.*, COUNT(orders.id) as order_count")
                                    .group("products.id")
                                    .order("order_count DESC")
                                    .limit(5)
    end
  end
end
