class SellersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_seller, only: [:show, :edit, :update, :dashboard]
  before_action :authorize_seller, only: [:edit, :update, :dashboard]
  
  def new
    # Check if the current user already has a seller profile
    if current_user.seller.present?
      redirect_to seller_dashboard_path, notice: "You already have a seller account"
      return
    end
    
    @seller = Seller.new
  end
  
  def create
    # Check if the current user already has a seller profile
    if current_user.seller.present?
      redirect_to seller_dashboard_path, notice: "You already have a seller account"
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
      
      redirect_to seller_dashboard_path, notice: "Your seller account has been created successfully!"
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
    # Seller dashboard with key metrics and links to seller functions
    @recent_orders = Order.joins(:product)
                         .where(products: { seller_id: @seller.id })
                         .order(created_at: :desc)
                         .limit(5)
    
    @total_sales = Order.joins(:product)
                        .where(products: { seller_id: @seller.id, status: "completed" })
                        .sum(:total_amount)
    
    @products_count = @seller.products.count
    
    @pending_orders_count = Order.joins(:product)
                                .where(products: { seller_id: @seller.id }, status: ["pending", "processing"])
                                .count
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
    params.require(:seller).permit(
      :business_name, :description, :location, :country, 
      :phone_number, :bank_account_details, :mobile_money_details
    )
  end
end
