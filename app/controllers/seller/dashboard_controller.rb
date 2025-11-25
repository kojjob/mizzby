class Seller::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_seller

  def index
    @seller = current_user.seller
    seller_product_ids = @seller.products.pluck(:id)

    # Core metrics
    @total_sales = Order.where(product_id: seller_product_ids)
                        .where(status: "completed")
                        .sum(:total_amount)

    @products_count = @seller.products.count
    @active_products_count = @seller.products.where(status: :active).count

    @pending_orders_count = Order.where(product_id: seller_product_ids)
                                 .where(status: [ "pending", "processing" ])
                                 .count

    @total_orders_count = Order.where(product_id: seller_product_ids).count
    @completed_orders_count = Order.where(product_id: seller_product_ids)
                                   .where(status: "completed").count

    # Time-based metrics
    @today_sales = Order.where(product_id: seller_product_ids)
                        .where(status: "completed")
                        .where("created_at >= ?", Time.current.beginning_of_day)
                        .sum(:total_amount)

    @weekly_sales = Order.where(product_id: seller_product_ids)
                         .where(status: "completed")
                         .where("created_at >= ?", 7.days.ago)
                         .sum(:total_amount)

    @monthly_sales = Order.where(product_id: seller_product_ids)
                          .where(status: "completed")
                          .where("created_at >= ?", 30.days.ago)
                          .sum(:total_amount)

    # Previous period for comparison
    @last_month_sales = Order.where(product_id: seller_product_ids)
                             .where(status: "completed")
                             .where(created_at: 60.days.ago..30.days.ago)
                             .sum(:total_amount)

    @sales_growth = calculate_growth(@monthly_sales, @last_month_sales)

    # Daily sales for chart (last 30 days)
    @daily_sales_data = Order.where(product_id: seller_product_ids)
                             .where(status: "completed")
                             .where("created_at >= ?", 30.days.ago)
                             .group("DATE(created_at)")
                             .sum(:total_amount)

    # Fill in missing dates with 0
    @chart_labels = (0..29).map { |i| (29 - i).days.ago.to_date }
    @chart_data = @chart_labels.map { |date| @daily_sales_data[date] || 0 }

    # Order status breakdown for pie chart
    @order_status_data = Order.where(product_id: seller_product_ids)
                              .group(:status)
                              .count

    # Top selling products
    @top_products = @seller.products
                           .joins(:orders)
                           .where(orders: { status: "completed" })
                           .group("products.id")
                           .select("products.*, COUNT(orders.id) as order_count, SUM(orders.total_amount) as revenue")
                           .order("revenue DESC")
                           .limit(5)

    # Recent orders
    @recent_orders = Order.includes(:user, :product)
                          .where(product_id: seller_product_ids)
                          .order(created_at: :desc)
                          .limit(5)

    # Reviews metrics
    @total_reviews = @seller.products.joins(:reviews).count
    @average_rating = @seller.products.joins(:reviews).average("reviews.rating")&.round(1) || 0

    # Product views (if tracked)
    @total_views = @seller.products.sum(:view_count) rescue 0

    # Earnings calculation
    commission_rate = @seller.commission_rate || 10
    @total_earnings = @total_sales * (1 - (commission_rate / 100.0))
    @pending_earnings = Order.where(product_id: seller_product_ids)
                             .where(status: [ "pending", "processing" ])
                             .sum(:total_amount) * (1 - (commission_rate / 100.0))

    # Conversion rate (orders / product views)
    @conversion_rate = @total_views > 0 ? ((@total_orders_count.to_f / @total_views) * 100).round(2) : 0
  end

  def sales
    @seller = current_user.seller
    seller_product_ids = @seller.products.pluck(:id)

    @orders = Order.where(product_id: seller_product_ids)
                   .includes(:user, :product)
                   .order(created_at: :desc)
                   .page(params[:page])

    @total_sales = Order.where(product_id: seller_product_ids)
                        .where(status: "completed")
                        .sum(:total_amount)

    @monthly_sales = Order.where(product_id: seller_product_ids)
                          .where(status: "completed")
                          .where("created_at >= ?", 30.days.ago)
                          .sum(:total_amount)
    
    @weekly_sales = Order.where(product_id: seller_product_ids)
                         .where(status: "completed")
                         .where("created_at >= ?", 7.days.ago)
                         .sum(:total_amount)
    
    @today_sales = Order.where(product_id: seller_product_ids)
                        .where(status: "completed")
                        .where("created_at >= ?", Time.current.beginning_of_day)
                        .sum(:total_amount)
    
    # Order counts by status
    @total_orders = Order.where(product_id: seller_product_ids).count
    @pending_orders = Order.where(product_id: seller_product_ids).where(status: ['pending', 'processing']).count
    @completed_orders = Order.where(product_id: seller_product_ids).where(status: 'completed').count
    @cancelled_orders = Order.where(product_id: seller_product_ids).where(status: 'cancelled').count
    
    # Average order value
    @average_order_value = @completed_orders > 0 ? (@total_sales / @completed_orders) : 0
    
    # Sales by day for chart (last 14 days)
    @daily_sales = Order.where(product_id: seller_product_ids)
                        .where(status: "completed")
                        .where("created_at >= ?", 14.days.ago)
                        .group("DATE(created_at)")
                        .sum(:total_amount)
    
    @chart_labels = (0..13).map { |i| (13 - i).days.ago.to_date }
    @chart_data = @chart_labels.map { |date| @daily_sales[date] || 0 }
    
    # Top selling products this month
    @top_products = @seller.products
                           .joins(:orders)
                           .where(orders: { status: "completed", created_at: 30.days.ago.. })
                           .group("products.id")
                           .select("products.*, COUNT(orders.id) as order_count, SUM(orders.total_amount) as revenue")
                           .order("revenue DESC")
                           .limit(5)
    
    # Growth calculation
    last_month_sales = Order.where(product_id: seller_product_ids)
                            .where(status: "completed")
                            .where(created_at: 60.days.ago..30.days.ago)
                            .sum(:total_amount)
    @sales_growth = last_month_sales > 0 ? ((@monthly_sales - last_month_sales) / last_month_sales.to_f * 100).round(1) : 0
  end

  def earnings
    @seller = current_user.seller
    seller_product_ids = @seller.products.pluck(:id)
    
    commission_rate = @seller.commission_rate || 10
    
    # Total earnings
    total_gross = Order.where(product_id: seller_product_ids)
                       .where(status: "completed")
                       .sum(:total_amount)
    @total_earnings = total_gross * (1 - (commission_rate / 100.0))
    @total_commission = total_gross * (commission_rate / 100.0)

    # Pending earnings
    pending_gross = Order.where(product_id: seller_product_ids)
                         .where(status: [ "pending", "processing" ])
                         .sum(:total_amount)
    @pending_earnings = pending_gross * (1 - (commission_rate / 100.0))
    
    # This month earnings
    this_month_gross = Order.where(product_id: seller_product_ids)
                            .where(status: "completed")
                            .where("created_at >= ?", Time.current.beginning_of_month)
                            .sum(:total_amount)
    @this_month_earnings = this_month_gross * (1 - (commission_rate / 100.0))
    
    # Last month earnings
    last_month_gross = Order.where(product_id: seller_product_ids)
                            .where(status: "completed")
                            .where(created_at: Time.current.last_month.beginning_of_month..Time.current.last_month.end_of_month)
                            .sum(:total_amount)
    @last_month_earnings = last_month_gross * (1 - (commission_rate / 100.0))
    
    # Earnings growth
    @earnings_growth = @last_month_earnings > 0 ? ((@this_month_earnings - @last_month_earnings) / @last_month_earnings * 100).round(1) : 0
    
    # Weekly earnings for chart (last 12 weeks)
    @weekly_earnings_data = Order.where(product_id: seller_product_ids)
                                 .where(status: "completed")
                                 .where("created_at >= ?", 12.weeks.ago)
                                 .group_by_week(:created_at)
                                 .sum(:total_amount)
                                 .transform_values { |v| v * (1 - (commission_rate / 100.0)) }
    
    # Monthly earnings for chart (last 6 months)
    @monthly_earnings_data = Order.where(product_id: seller_product_ids)
                                  .where(status: "completed")
                                  .where("created_at >= ?", 6.months.ago)
                                  .group("DATE_TRUNC('month', created_at)")
                                  .sum(:total_amount)
    
    @chart_labels = (0..5).map { |i| (5 - i).months.ago.strftime("%b %Y") }
    @chart_data = (0..5).map do |i|
      month_start = (5 - i).months.ago.beginning_of_month
      month_gross = @monthly_earnings_data.find { |k, _| k.to_date.beginning_of_month == month_start.to_date }&.last || 0
      (month_gross * (1 - (commission_rate / 100.0))).round(2)
    end
    
    # Recent payouts (if you have a payouts table)
    @recent_payouts = [] # Placeholder for payout history
    
    # Earnings by product
    @earnings_by_product = @seller.products
                                  .joins(:orders)
                                  .where(orders: { status: "completed" })
                                  .group("products.id", "products.name")
                                  .select("products.id, products.name, SUM(orders.total_amount) as gross_revenue")
                                  .order("gross_revenue DESC")
                                  .limit(10)
                                  .map { |p| { id: p.id, name: p.name, earnings: (p.gross_revenue * (1 - (commission_rate / 100.0))).round(2) } }

    @commission_rate = commission_rate
    
    # Available for withdrawal (total - pending)
    @available_balance = @total_earnings
  end

  private

  def calculate_growth(current, previous)
    return 0 if previous.nil? || previous == 0
    ((current - previous) / previous.to_f * 100).round(1)
  end

  def require_seller
    unless current_user.seller.present?
      redirect_to new_seller_path, alert: "You need to create a seller account first"
    end
  end
end
