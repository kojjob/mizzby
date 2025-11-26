class Account::DashboardController < Account::BaseController
  def index
    @user = current_user

    # Orders data
    @recent_orders = current_user.orders.includes(:order_items, :product).order(created_at: :desc).limit(5)
    @total_orders = current_user.orders.count
    @completed_orders = current_user.orders.where(status: "completed").count
    @pending_orders = current_user.orders.where(status: [ "pending", "processing" ]).count

    # Total spent
    @total_spent = current_user.orders.where(status: "completed").sum(:total_amount)
    @this_month_spent = current_user.orders.where(status: "completed")
                                           .where("created_at >= ?", Time.current.beginning_of_month)
                                           .sum(:total_amount)

    # Wishlist
    @wishlist_count = current_user.wishlist_items.count
    @wishlist_items = current_user.wishlist_items.includes(product: [ :category, images_attachments: :blob ]).limit(4)

    # Reviews
    @reviews_count = current_user.respond_to?(:reviews) ? current_user.reviews.count : 0

    # Addresses - must be set before calculate_profile_completion
    @addresses_count = current_user.respond_to?(:addresses) ? current_user.addresses.count : 0
    @default_address = current_user.respond_to?(:addresses) ? current_user.addresses.find_by(default: true) : nil

    # Account completion percentage
    @profile_completion = calculate_profile_completion
  end

  private

  def calculate_profile_completion
    completion = 0
    completion += 20 if @user.email.present?
    completion += 20 if @user.first_name.present? && @user.last_name.present?
    completion += 20 if @user.respond_to?(:phone) && @user.phone.present?
    completion += 20 if @addresses_count.to_i > 0
    completion += 20 if @user.respond_to?(:profile_picture) && @user.profile_picture.attached?
    completion
  end
end
