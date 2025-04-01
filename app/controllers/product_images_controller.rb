class ProductImagesController < ApplicationController
  before_action :set_product_image, only: %i[ show edit update destroy ]

  # GET /product_images or /product_images.json
  def index
    @product_images = ProductImage.all
  end

  # GET /product_images/1 or /product_images/1.json
  def show
  end

  # GET /product_images/new
  def new
    @product_image = ProductImage.new
  end

  # GET /product_images/1/edit
  def edit
  end

  # POST /product_images or /product_images.json
  def create
    @product_image = ProductImage.new(product_image_params)

    respond_to do |format|
      if @product_image.save
        format.html { redirect_to @product_image, notice: "Product image was successfully created." }
        format.json { render :show, status: :created, location: @product_image }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_images/1 or /product_images/1.json
  def update
    respond_to do |format|
      if @product_image.update(product_image_params)
        format.html { redirect_to @product_image, notice: "Product image was successfully updated." }
        format.json { render :show, status: :ok, location: @product_image }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_images/1 or /product_images/1.json
  def destroy
    @product_image.destroy!

    respond_to do |format|
      format.html { redirect_to product_images_path, status: :see_other, notice: "Product image was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_image
      @product_image = ProductImage.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def product_image_params
      params.expect(product_image: [ :product_id, :position, :alt_text ])
    end
end
