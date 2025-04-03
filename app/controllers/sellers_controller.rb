class SellersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_seller, only: [:show, :edit, :update, :dashboard]
  before_action :authorize_seller, only: [:edit, :update, :dashboard]

  def new
    # Check if the current user already has a seller profile
    if current_user.seller.present?
      redirect_to dashboard_sellers_path, notice: "You already have a seller account"
      return
    end

    @seller = Seller.new
  end

  def create
    # Check if the current user already has a seller profile
    if current_user.seller.present?
      redirect_to dashboard_sellers_path, notice: "You already have a seller account"
      return
    end

    @seller = Seller.new(seller_params)
    @seller.user = current_user
    @seller.commission_rate = 10.0 # Default commission rate

    if @seller.save
      # Log the creation of seller account
      UserActivity.create(
        user: current_user,
        activity_type: "seller_registration",
        title: "Registered as a seller",
        description: "Created seller account with business name: #{@seller.business_name}",
        icon: "store",
        color: "purple"
      )

      redirect_to dashboard_sellers_path, notice: "Your seller account has been created successfully!"
    else
      render :new
    end
  end

  def show
    # Public profile page for a seller
    @seller = Seller.find(params[:id])
    @products = @seller.products.where(published: true).order(created_at: :desc).limit(12)
  end

  def edit
    # Only allow editing your own seller profile
  end

  def update
    if @seller.update(seller_params)
      redirect_to seller_dashboard_path, notice: "Your seller profile has been updated successfully"
    else
      render :edit
    end
  end

  def dashboard
    @seller = current_user.seller
    
    # Use subqueries instead of joins for all order-related queries
    seller_product_ids = @seller.products.pluck(:id)
    
    @total_sales = Order.where(product_id: seller_product_ids)
                      .where(status: "completed")
                      .sum(:total_amount)
    
    @products_count = @seller.products.count
    
    @pending_orders_count = Order.where(product_id: seller_product_ids)
                                .where(status: ["pending", "processing"])
                                .count
    
    # For recent orders, use the same approach
    @recent_orders = Order.where(product_id: seller_product_ids)
                        .includes(:user) # Include any associations you need in the view
                        .order(created_at: :desc)
                        .limit(5)

    @recent_orders = Order.includes(:user)
                     .where(product_id: seller_product_ids)
                     .order(created_at: :desc)
                     .limit(5)
  end

  def store_settings
    @seller = current_user.seller
    redirect_to new_seller_path, alert: "You need to create a seller account first" unless @seller
  end

  def update_store_settings
    @seller = current_user.seller

    if @seller.update(store_params)
      redirect_to seller_store_settings_path, notice: "Your store settings have been updated successfully"
    else
      render :store_settings
    end
  end

  def verify_domain
    @seller = current_user.seller

    # This would typically involve DNS verification
    # For now, we'll just mark it as verified
    if @seller.update(domain_verified: true)
      redirect_to seller_store_settings_path, notice: "Your domain has been verified successfully"
    else
      redirect_to seller_store_settings_path, alert: "There was an error verifying your domain"
    end
  end

  private

  def set_seller
    @seller = current_user.seller

    # If we're on the public show page, the seller is set from the URL parameter
    return if action_name == "show"

    # For other actions, redirect if the user doesn't have a seller account
    redirect_to new_seller_path, alert: "You need to create a seller account first" unless @seller
  end

  def authorize_seller
    # Make sure users can only access their own seller information
    unless @seller && @seller.user_id == current_user.id
      redirect_to root_path, alert: "You don't have permission to access that page"
    end
  end

  def seller_params
    # Base parameters that all users can set
    base_params = params.require(:seller).permit(
      :business_name, :description, :location, :country,
      :phone_number, :bank_account_details, :mobile_money_details
    )

    # Admin-only parameters
    if current_user&.admin? || current_user&.super_admin?
      base_params.merge!(params.require(:seller).permit(
        :user_id, :verified, :commission_rate, :store_name, :store_slug,
        :custom_domain, :domain_verified,
        store_settings: [:enabled, :logo, :banner, :primary_color, :secondary_color, :font, :custom_css]
      ))
    end

    base_params
  end

  def store_params
    params.require(:seller).permit(
      :store_name, :store_slug, :custom_domain,
      store_settings: [:enabled, :logo, :banner, :primary_color, :secondary_color, :font, :custom_css]
    )
  end
end
