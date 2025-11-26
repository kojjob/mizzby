class Account::DownloadsController < Account::BaseController
  def index
    @downloads = current_user.download_links.includes(:product).order(created_at: :desc)
  end
end
