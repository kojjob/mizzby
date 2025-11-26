class DownloadLinksController < ApplicationController
  before_action :authenticate_user!, only: [ :download ]
  before_action :set_download_link, only: %i[ show edit update destroy ]
  before_action :set_download_link_by_token, only: [ :download ]

  # GET /download/:token - Download the file
  def download
    unless @download_link.valid_for_download?
      if @download_link.expired?
        redirect_to account_downloads_path, alert: "This download link has expired."
      elsif @download_link.limit_reached?
        redirect_to account_downloads_path, alert: "Download limit reached for this file."
      else
        redirect_to account_downloads_path, alert: "This download is no longer available."
      end
      return
    end

    # Verify ownership
    unless @download_link.user == current_user
      redirect_to account_downloads_path, alert: "You don't have permission to download this file."
      return
    end

    # Increment download count
    @download_link.increment_download!

    # Get the product's downloadable file
    product = @download_link.product

    if product.respond_to?(:file) && product.file.attached?
      redirect_to rails_blob_path(product.file, disposition: "attachment"), allow_other_host: true
    elsif product.respond_to?(:download_file) && product.download_file.attached?
      redirect_to rails_blob_path(product.download_file, disposition: "attachment"), allow_other_host: true
    else
      # Fallback - redirect to product page with message
      redirect_to product_path(product), notice: "Your download is ready. Please contact support if you have issues."
    end
  end

  # GET /download_links or /download_links.json
  def index
    @download_links = DownloadLink.all
  end

  # GET /download_links/1 or /download_links/1.json
  def show
  end

  # GET /download_links/new
  def new
    @download_link = DownloadLink.new
  end

  # GET /download_links/1/edit
  def edit
  end

  # POST /download_links or /download_links.json
  def create
    @download_link = DownloadLink.new(download_link_params)

    respond_to do |format|
      if @download_link.save
        format.html { redirect_to @download_link, notice: "Download link was successfully created." }
        format.json { render :show, status: :created, location: @download_link }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @download_link.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /download_links/1 or /download_links/1.json
  def update
    respond_to do |format|
      if @download_link.update(download_link_params)
        format.html { redirect_to @download_link, notice: "Download link was successfully updated." }
        format.json { render :show, status: :ok, location: @download_link }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @download_link.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /download_links/1 or /download_links/1.json
  def destroy
    @download_link.destroy!

    respond_to do |format|
      format.html { redirect_to download_links_path, status: :see_other, notice: "Download link was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_download_link
      @download_link = DownloadLink.find(params.expect(:id))
    end

    def set_download_link_by_token
      @download_link = DownloadLink.find_by!(token: params[:token])
    rescue ActiveRecord::RecordNotFound
      redirect_to account_downloads_path, alert: "Download link not found or has been removed."
    end

    # Only allow a list of trusted parameters through.
    def download_link_params
      params.expect(download_link: [ :product_id, :user_id, :token, :expires_at, :download_count, :download_limit, :active, :order_id ])
    end
end
