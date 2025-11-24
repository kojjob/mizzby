module Admin
  class SellersController < BaseController
    before_action :set_seller, only: [ :show, :edit, :update, :verify, :suspend, :products, :orders, :analytics ]
    before_action -> { authorize_action(:manage_sellers) }
    before_action -> { authorize_action(:approve_sellers) }, only: [ :verify, :suspend ]

    def index
      @sellers = Seller.includes(:user)
                      .order(created_at: :desc)
                      .page(params[:page])
                      .per(25)

      # Filter by verification status
      @sellers = @sellers.where(verified: params[:verified] == "true") if params[:verified].present?

      # Search by business name or user details
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @sellers = @sellers.joins(:user)
                          .where("business_name ILIKE ? OR users.first_name ILIKE ? OR users.last_name ILIKE ? OR users.email ILIKE ?",
                                search_term, search_term, search_term, search_term)
      end

      # Filter by country
      @sellers = @sellers.where(country: params[:country]) if params[:country].present?

      # Performance filters
      if params[:min_rating].present?
        min_rating = params[:min_rating].to_f
        @sellers = @sellers.where("acceptance_rate >= ?", min_rating)
      end
    end

    def show
      # Get seller's stats
      @products_count = @seller.products.count
      @orders_count = Order.joins(order_items: :product).where(products: { seller_id: @seller.id }).distinct.count
      @total_sales = Order.joins(order_items: :product)
                          .where(products: { seller_id: @seller.id })
                          .where(status: "completed")
                          .sum(:total_amount)

      # Get seller's recent products
      @recent_products = @seller.products.order(created_at: :desc).limit(5)

      # Get seller's recent orders
      @recent_orders = Order.joins(order_items: :product)
                            .where(products: { seller_id: @seller.id })
                            .distinct
                            .order(created_at: :desc)
                            .limit(5)

      # Initialize empty arrays if no data is available
      @recent_products ||= []
      @recent_orders ||= []
    end

    def new
      @seller = Seller.new
      @users = User.where.not(id: Seller.pluck(:user_id))
                  .order(:first_name, :last_name)
    end

    def create
      @seller = Seller.new(seller_params)

      if @seller.save
        flash[:success] = "Seller was successfully created."
        redirect_to admin_seller_path(@seller)
      else
        @users = User.where.not(id: Seller.pluck(:user_id))
                    .order(:first_name, :last_name)
        flash.now[:error] = "There was a problem creating the seller."
        render :new
      end
    end

    def edit
    end

    def update
      if @seller.update(seller_params)
        flash[:success] = "Seller was successfully updated."
        redirect_to admin_seller_path(@seller)
      else
        flash.now[:error] = "There was a problem updating the seller."
        render :edit
      end
    end

    def verify
      if @seller.update(verified: true)
        # Send notification to seller
        @seller.user.notifications.create(
          title: "Your seller account has been verified!",
          message: "Congratulations! Your seller account has been verified. You can now start selling products on our platform.",
          notification_type: :success,
          notifiable: @seller
        )

        flash[:success] = "Seller has been verified successfully."
      else
        flash[:error] = "Could not verify seller: #{@seller.errors.full_messages.join(', ')}"
      end

      redirect_to admin_seller_path(@seller)
    end

    def suspend
      if @seller.update(verified: false)
        # Send notification to seller
        @seller.user.notifications.create(
          title: "Your seller account has been suspended",
          message: "Your seller account has been suspended. Please contact support for more information.",
          notification_type: :warning,
          notifiable: @seller
        )

        flash[:success] = "Seller has been suspended successfully."
      else
        flash[:error] = "Could not suspend seller: #{@seller.errors.full_messages.join(', ')}"
      end

      redirect_to admin_seller_path(@seller)
    end

    def products
      @products = @seller.products
                        .order(created_at: :desc)
                        .page(params[:page])
                        .per(25)

      render "admin/products/index"
    end

    def orders
      @orders = Order.joins(order_items: :product)
                    .where(products: { seller_id: @seller.id })
                    .includes(:user, order_items: :product)
                    .distinct
                    .order(created_at: :desc)
                    .page(params[:page])
                    .per(25)

      render "admin/orders/index"
    end

    def analytics
      # Get sales data for the last 30 days
      @daily_sales = Order.joins(order_items: :product)
                          .where(products: { seller_id: @seller.id })
                          .where(status: "completed")
                          .where("orders.created_at >= ?", 30.days.ago)
                          .group("DATE(orders.created_at)")
                          .sum(:total_amount)

      # Get top products
      @top_products = @seller.products
                            .joins(order_items: :order)
                            .group("products.id")
                            .select("products.*, COUNT(DISTINCT orders.id) as orders_count, SUM(orders.total_amount) as total_sales")
                            .order("total_sales DESC")
                            .limit(5)

      # Customer analytics
      @customer_count = Order.joins(order_items: :product)
                            .where(products: { seller_id: @seller.id })
                            .distinct
                            .count(:user_id)

      @repeat_customer_count = Order.joins(order_items: :product)
                                  .where(products: { seller_id: @seller.id })
                                  .group("orders.user_id")
                                  .having("COUNT(DISTINCT orders.id) > 1")
                                  .count.size

      # Commission data
      @total_commission = Order.joins(order_items: :product)
                              .where(products: { seller_id: @seller.id })
                              .where(status: "completed")
                              .sum("orders.total_amount * ?", @seller.commission_rate || 0.1)

      render "admin/sellers/analytics"
    end

    private

    def set_seller
      @seller = Seller.find(params[:id])
    end

    def seller_params
      params.require(:seller).permit(
        :user_id, :business_name, :description, :location, :country,
        :phone_number, :verified, :commission_rate, :bank_account_details,
        :mobile_money_details, :store_name, :store_slug, :custom_domain, :domain_verified,
        store_settings: [ :enabled, :logo, :banner, :primary_color, :secondary_color, :font, :custom_css ]
      )
    end
  end
end
