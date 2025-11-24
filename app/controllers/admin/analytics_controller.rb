module Admin
  class AnalyticsController < BaseController
    before_action -> { authorize_action(:view_analytics) }

    def index
      # Set date range for analytics
      @start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago.to_date
      @end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today

      # Summary statistics
      @stats = {
        total_sales: Order.where(status: "completed")
                          .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                          .sum(:total_amount),

        total_orders: Order.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                          .count,

        total_customers: Order.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                             .distinct.count(:user_id),

        avg_order_value: Order.where(status: "completed")
                             .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                             .average(:total_amount)&.round(2) || 0,

        new_users: User.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                      .count,

        new_products: Product.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                            .count
      }

      # Daily sales data for chart
      @daily_sales = Order.where(status: "completed")
                          .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                          .group("DATE(created_at)")
                          .sum(:total_amount)

      # Format for charting library
      @daily_sales_chart = @daily_sales.map { |date, amount| { date: date, amount: amount } }

      # Daily orders count for chart
      @daily_orders = Order.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                          .group("DATE(created_at)")
                          .count

      # Format for charting library
      @daily_orders_chart = @daily_orders.map { |date, count| { date: date, count: count } }

      # Top selling products
      @top_products = Product.joins(order_items: :order)
                            .where(orders: { status: "completed", created_at: @start_date.beginning_of_day..@end_date.end_of_day })
                            .group("products.id")
                            .select("products.*, COUNT(DISTINCT orders.id) as orders_count, SUM(orders.total_amount) as total_sales")
                            .order("total_sales DESC")
                            .limit(10)

      # Top categories
      @top_categories = Category.joins(products: { order_items: :order })
                               .where(orders: { status: "completed", created_at: @start_date.beginning_of_day..@end_date.end_of_day })
                               .group("categories.id")
                               .select("categories.*, COUNT(DISTINCT orders.id) as orders_count, SUM(orders.total_amount) as total_sales")
                               .order("total_sales DESC")
                               .limit(10)

      # Top customers
      @top_customers = User.joins(:orders)
                          .where(orders: { status: "completed", created_at: @start_date.beginning_of_day..@end_date.end_of_day })
                          .group("users.id")
                          .select("users.*, COUNT(orders.id) as orders_count, SUM(orders.total_amount) as total_spent")
                          .order("total_spent DESC")
                          .limit(10)

      # Top sellers
      @top_sellers = Seller.joins(products: { order_items: :order })
                          .where(orders: { status: "completed", created_at: @start_date.beginning_of_day..@end_date.end_of_day })
                          .group("sellers.id")
                          .select("sellers.*, COUNT(DISTINCT orders.id) as orders_count, SUM(orders.total_amount) as total_sales")
                          .order("total_sales DESC")
                          .limit(10)
    end

    def sales
      # More detailed sales analytics
      @start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago.to_date
      @end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today

      # Sales by payment processor
      @sales_by_processor = Order.where(status: "completed")
                                 .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                                 .group(:payment_processor)
                                 .sum(:total_amount)

      # Sales by product type (digital vs physical)
      @sales_by_type = Order.joins(order_items: :product)
                           .where(status: "completed")
                           .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                           .group("products.is_digital")
                           .sum(:total_amount)

      # Format for display
      @sales_by_type = {
        "Digital" => @sales_by_type[true] || 0,
        "Physical" => @sales_by_type[false] || 0
      }

      # Monthly sales for year-over-year comparison
      current_year_start = Date.today.beginning_of_year
      previous_year_start = 1.year.ago.beginning_of_year

      @monthly_sales_current_year = Order.where(status: "completed")
                                        .where(created_at: current_year_start..Date.today)
                                        .group("DATE_TRUNC('month', created_at)")
                                        .sum(:total_amount)

      @monthly_sales_previous_year = Order.where(status: "completed")
                                         .where(created_at: previous_year_start..1.year.ago.end_of_year)
                                         .group("DATE_TRUNC('month', created_at)")
                                         .sum(:total_amount)
    end

    def products
      # Product performance analytics
      @start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago.to_date
      @end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today

      # Products with most recent orders
      @most_viewed_products = Product.joins(order_items: :order)
                                    .group("products.id")
                                    .select("products.*, MAX(orders.created_at) as last_ordered_at")
                                    .order("last_ordered_at DESC")
                                    .limit(10)

      # Products with highest order count
      @best_converting_products = Product.joins(order_items: :order)
                                       .group("products.id")
                                       .select("products.*, COUNT(DISTINCT orders.id) as orders_count")
                                       .order("orders_count DESC")
                                       .limit(10)

      # Products with most reviews
      @most_reviewed_products = Product.joins(:reviews)
                                      .group("products.id")
                                      .select("products.*, COUNT(reviews.id) as reviews_count, AVG(reviews.rating) as avg_rating")
                                      .order("reviews_count DESC")
                                      .limit(10)

      # Highest rated products
      @highest_rated_products = Product.joins(:reviews)
                                      .group("products.id")
                                      .select("products.*, COUNT(reviews.id) as reviews_count, AVG(reviews.rating) as avg_rating")
                                      .having("COUNT(reviews.id) >= 3") # Minimum review threshold
                                      .order("avg_rating DESC")
                                      .limit(10)
    end

    def customers
      # Customer analytics
      @start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago.to_date
      @end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today

      # Summary statistics
      @stats = {
        total_customers: Order.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                             .distinct.count(:user_id),

        new_users: User.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                      .count,

        repeat_customers: Order.select(:user_id)
                              .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                              .group(:user_id)
                              .having("COUNT(*) > 1")
                              .count.size,

        avg_orders_per_customer: Order.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                                     .group(:user_id)
                                     .count
                                     .values
                                     .instance_eval { sum.to_f / size rescue 0 },

        avg_order_value: Order.where(status: "completed", created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                            .average(:total_amount).to_f
      }

      # New users by day
      @new_users_by_day = User.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                             .group("DATE(created_at)")
                             .count

      # Calculate repeat purchase rate
      total_customers = Order.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                            .distinct.count(:user_id)
      repeat_customers = @stats[:repeat_customers]
      @repeat_purchase_rate = total_customers > 0 ? (repeat_customers.to_f / total_customers) * 100 : 0

      # Calculate conversion rate (estimate based on users vs orders)
      total_users = User.count
      total_orders = Order.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day).count
      @conversion_rate = total_users > 0 ? (total_orders.to_f / total_users) * 100 : 0

      # Customer lifetime value
      @customer_ltv = User.joins(:orders)
                         .where(orders: { status: "completed" })
                         .group("users.id")
                         .select("users.*, SUM(orders.total_amount) as lifetime_value, COUNT(orders.id) as orders_count")
                         .order("lifetime_value DESC")
                         .limit(20)

      # Customers by country
      @customers_by_country = User.group(:country)
                                 .count

      # Recent new users
      @recent_users = User.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                         .order(created_at: :desc)
                         .limit(10)

      # Repeat purchase rate
      total_customers = User.joins(:orders).select("DISTINCT users.id").count
      repeat_customers = User.joins(:orders)
                            .group("users.id")
                            .having("COUNT(orders.id) > 1")
                            .count.size

      @repeat_purchase_rate = total_customers > 0 ? (repeat_customers.to_f / total_customers) * 100 : 0
    end

    def export
      # Export analytics data to CSV
      @start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago.to_date
      @end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today

      report_type = params[:report_type] || "sales"

      case report_type
      when "sales"
        @data = Order.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                    .includes(:user, order_items: :product)
                    .order(created_at: :desc)

        csv_data = generate_sales_csv(@data)
        filename = "sales_report_#{@start_date.strftime('%Y%m%d')}_#{@end_date.strftime('%Y%m%d')}.csv"
      when "products"
        @data = Product.includes(:category, :seller)
                      .order(created_at: :desc)

        csv_data = generate_products_csv(@data)
        filename = "products_report_#{Date.today.strftime('%Y%m%d')}.csv"
      when "customers"
        @data = User.includes(:orders)
                   .order(created_at: :desc)

        csv_data = generate_customers_csv(@data)
        filename = "customers_report_#{Date.today.strftime('%Y%m%d')}.csv"
      else
        flash[:error] = "Invalid report type"
        return redirect_to admin_analytics_path
      end

      send_data csv_data, filename: filename, type: "text/csv", disposition: "attachment"
    end

    private

    def generate_sales_csv(data)
      require "csv"

      CSV.generate(headers: true) do |csv|
        csv << [ "Order ID", "Date", "Customer", "Email", "Product", "Amount", "Status", "Payment Method" ]

        data.each do |order|
          csv << [
            order.id,
            order.created_at.strftime("%Y-%m-%d %H:%M"),
            order.user&.full_name || "Unknown",
            order.user&.email || "Unknown",
            order.order_items.first&.product&.name || "Unknown",
            order.total_amount,
            order.status,
            order.payment_processor
          ]
        end
      end
    end

    def generate_products_csv(data)
      require "csv"

      CSV.generate(headers: true) do |csv|
        csv << [ "Product ID", "Name", "Category", "Seller", "Price", "Created At", "Type", "Stock", "Status" ]

        data.each do |product|
          csv << [
            product.id,
            product.name,
            product.category&.name || "Uncategorized",
            product.seller&.business_name || "Unknown",
            product.price,
            product.created_at.strftime("%Y-%m-%d"),
            product.is_digital? ? "Digital" : "Physical",
            product.stock_quantity,
            product.status
          ]
        end
      end
    end

    def generate_customers_csv(data)
      require "csv"

      CSV.generate(headers: true) do |csv|
        csv << [ "User ID", "Name", "Email", "Joined", "Orders", "Total Spent", "Last Order" ]

        data.each do |user|
          csv << [
            user.id,
            user.full_name,
            user.email,
            user.created_at.strftime("%Y-%m-%d"),
            user.orders.count,
            user.orders.where(status: "completed").sum(:total_amount),
            user.orders.order(created_at: :desc).first&.created_at&.strftime("%Y-%m-%d") || "N/A"
          ]
        end
      end
    end
  end
end
