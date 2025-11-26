class Account::WishlistController < Account::BaseController
  def index
    @wishlist_items = current_user.wishlist_items.includes(:product).order(created_at: :desc)
  end

  def clear
    current_user.wishlist_items.destroy_all
    redirect_to account_wishlist_path, notice: "Wishlist cleared."
  end
end
