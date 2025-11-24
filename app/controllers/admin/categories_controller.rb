module Admin
  class CategoriesController < BaseController
    before_action :set_category, only: [ :show, :edit, :update, :destroy, :products ]
    before_action -> { authorize_action(:manage_categories) }

    def index
      @categories = Category.includes(:parent)
                          .order(:position, :name)
                          .page(params[:page])
                          .per(50)

      # Filter by parent category
      @categories = @categories.where(parent_id: params[:parent_id]) if params[:parent_id].present?

      # Filter by visibility
      @categories = @categories.where(visible: params[:visible] == "true") if params[:visible].present?

      # Search by name
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @categories = @categories.where("name ILIKE ? OR description ILIKE ?", search_term, search_term)
      end
    end

    def show
      @subcategories = @category.subcategories.order(:position, :name)
      @products_count = Product.where(category_id: [ @category.id ] + @subcategories.pluck(:id)).count
    end

    def new
      @category = Category.new
      @parents = Category.where(parent_id: nil).order(:name)
    end

    def create
      @category = Category.new(category_params)

      if @category.save
        flash[:success] = "Category was successfully created."
        redirect_to admin_category_path(@category)
      else
        @parents = Category.where(parent_id: nil).order(:name)
        flash.now[:error] = "There was a problem creating the category."
        render :new
      end
    end

    def edit
      @parents = Category.where(parent_id: nil)
                        .where.not(id: @category.id)
                        .order(:name)
    end

    def update
      # Prevent setting a category as its own parent
      if category_params[:parent_id].to_i == @category.id
        flash[:error] = "A category cannot be its own parent."
        @parents = Category.where(parent_id: nil)
                          .where.not(id: @category.id)
                          .order(:name)
        return render :edit
      end

      # Prevent setting a descendant as parent (would create a loop)
      if category_params[:parent_id].present? &&
         @category.subcategory_ids.include?(category_params[:parent_id].to_i)
        flash[:error] = "Cannot set a subcategory as parent (would create a loop)."
        @parents = Category.where(parent_id: nil)
                          .where.not(id: @category.id)
                          .order(:name)
        return render :edit
      end

      if @category.update(category_params)
        flash[:success] = "Category was successfully updated."
        redirect_to admin_category_path(@category)
      else
        @parents = Category.where(parent_id: nil)
                          .where.not(id: @category.id)
                          .order(:name)
        flash.now[:error] = "There was a problem updating the category."
        render :edit
      end
    end

    def destroy
      # Check if category has subcategories
      if @category.subcategories.exists?
        flash[:error] = "Cannot delete a category with subcategories."
        return redirect_to admin_category_path(@category)
      end

      # Check if category has products
      if Product.where(category_id: @category.id).exists?
        flash[:error] = "Cannot delete a category with products."
        return redirect_to admin_category_path(@category)
      end

      if @category.destroy
        flash[:success] = "Category was successfully deleted."
        redirect_to admin_categories_path
      else
        flash[:error] = "Category could not be deleted: #{@category.errors.full_messages.join(', ')}"
        redirect_to admin_category_path(@category)
      end
    end

    def products
      # Get all products in this category and its subcategories
      category_ids = [ @category.id ] + @category.subcategories.pluck(:id)

      @products = Product.where(category_id: category_ids)
                        .includes(:seller)
                        .order(created_at: :desc)
                        .page(params[:page])
                        .per(25)

      render "admin/products/index"
    end

    # Reorder categories via AJAX
    def reorder
      params[:order].each_with_index do |id, index|
        Category.where(id: id).update_all(position: index + 1)
      end

      head :ok
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(
        :name, :description, :slug, :parent_id, :position,
        :visible, :icon_name, :icon_color
      )
    end
  end
end
