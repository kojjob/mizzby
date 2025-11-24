module Sellers
  class StoreCategoriesController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_seller
    before_action :set_store
    before_action :set_store_category, only: [ :edit, :update, :destroy ]

    def index
      @store_categories = @store.store_categories.order(position: :asc)
    end

    def new
      @store_category = @store.store_categories.new
    end

    def create
      @store_category = @store.store_categories.new(store_category_params)

      if @store_category.save
        redirect_to sellers_store_categories_path, notice: "Category was successfully created."
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @store_category.update(store_category_params)
        redirect_to sellers_store_categories_path, notice: "Category was successfully updated."
      else
        render :edit
      end
    end

    def destroy
      @store_category.destroy
      redirect_to sellers_store_categories_path, notice: "Category was successfully deleted."
    end

    def sort
      params[:store_category].each_with_index do |id, index|
        StoreCategory.where(id: id).update_all(position: index + 1)
      end

      head :ok
    end

    private

    def ensure_seller
      redirect_to new_seller_path unless current_user.seller?
    end

    def set_store
      @store = current_user.seller.store
    end

    def set_store_category
      @store_category = @store.store_categories.find(params[:id])
    end

    def store_category_params
      params.require(:store_category).permit(:name, :description, :position)
    end
  end
end
