class CategoriesController < ApplicationController
  before_action :set_category, only: %i[ edit update destroy ]

  # GET /categories or /categories.json
  def index
    @categories = Category.where(visible: true).order(:position)
  end

  # GET /categories/1 or /categories/1.json
  def show
    @category = find_category(params[:id])
    # Initialize products to at least an empty array
    @products = @category.products.where(published: true) rescue []
  rescue ActiveRecord::RecordNotFound
    redirect_to categories_path, alert: "Category not found"
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories or /categories.json
  def create
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to @category, notice: "Category was successfully created." }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1 or /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: "Category was successfully updated." }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1 or /categories/1.json
  def destroy
    @category.destroy!

    respond_to do |format|
      format.html { redirect_to categories_path, status: :see_other, notice: "Category was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_category
    @category = find_category(params[:id])
  end

  # Find category by ID or slug with fuzzy matching
  def find_category(id_or_slug)
    if id_or_slug.to_s.match?(/\A\d+\z/)
      Category.find(id_or_slug)
    else
      # Try exact slug match first
      category = Category.find_by(slug: id_or_slug)
      return category if category

      # Try exact name match
      category = Category.find_by(name: id_or_slug.titleize)
      return category if category

      # Try partial/fuzzy slug match (e.g., "courses" matches "courses-education")
      category = Category.where("slug ILIKE ?", "#{id_or_slug}%").first
      return category if category

      # Try partial name match
      category = Category.where("LOWER(name) ILIKE ?", "%#{id_or_slug.downcase}%").first
      return category if category

      raise ActiveRecord::RecordNotFound, "Category not found"
    end
  end

  # Only allow a list of trusted parameters through.
  def category_params
    params.expect(category: [ :name, :description, :slug, :parent_id, :position, :visible, :icon_name, :icon_color ])
  end
end
