class Account::OrdersController < Account::BaseController
  def index
    @orders = current_user.orders.includes(:product).order(created_at: :desc)
  end

  def show
    @order = current_user.orders.find(params[:id])
  end
end
