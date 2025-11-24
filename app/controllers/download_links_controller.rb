class DownloadLinksController < ApplicationController
  before_action :set_download_link, only: %i[ show edit update destroy ]

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

    # Only allow a list of trusted parameters through.
    def download_link_params
      params.expect(download_link: [ :product_id, :user_id, :token, :expires_at, :download_count, :download_limit, :active, :order_id ])
    end
end
