class Seller::ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_seller
  before_action :set_product, only: [ :show, :edit, :update, :destroy ]

  def index
    @products = current_user.seller.products
                  .includes(:category)
                  .with_attached_images
                  .order(created_at: :desc)
    
    # Pre-calculate stats to avoid N+1 in view
    @total_count = @products.size
    @published_count = @products.count(&:published?)
    @draft_count = @total_count - @published_count
    @digital_count = @products.count { |p| p.product_type_digital? }
  end

  def show
  end

  def new
    @product = current_user.seller.products.build
  end

  def create
    @product = current_user.seller.products.build(product_params)

    if @product.save
      redirect_to seller_products_path, notice: "Product created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to seller_product_path(@product), notice: "Product updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to seller_products_path, notice: "Product deleted successfully."
  end

  # Bulk listing actions
  def bulk_new
    @categories = Category.order(:name)
    @products = 5.times.map { current_user.seller.products.build }
  end

  def bulk_create
    @categories = Category.order(:name)
    results = { success: [], errors: [] }

    # Handle CSV upload
    if params[:csv_file].present?
      results = process_csv_upload(params[:csv_file])
    # Handle form-based bulk creation
    elsif params[:products].present?
      results = process_bulk_form(params[:products])
    else
      redirect_to bulk_new_seller_products_path, alert: "Please provide products via form or CSV upload."
      return
    end

    if results[:errors].empty?
      redirect_to seller_products_path, notice: "Successfully created #{results[:success].count} product(s)!"
    elsif results[:success].any?
      flash[:notice] = "Created #{results[:success].count} product(s)."
      flash[:alert] = "Failed to create #{results[:errors].count} product(s): #{results[:errors].first(3).join(', ')}#{results[:errors].count > 3 ? '...' : ''}"
      redirect_to seller_products_path
    else
      flash.now[:alert] = "Failed to create products: #{results[:errors].first(5).join(', ')}"
      @products = 5.times.map { current_user.seller.products.build }
      render :bulk_new, status: :unprocessable_entity
    end
  end

  def bulk_template
    csv_data = CSV.generate(headers: true) do |csv|
      csv << [
        "name", "description", "price", "discounted_price", "category_name",
        "stock_quantity", "sku", "brand", "condition", "country_of_origin",
        "is_digital", "product_type", "meta_title", "meta_description", "tags"
      ]
      # Example row
      csv << [
        "Example Product", "Product description here", "29.99", "24.99", "Electronics",
        "100", "SKU-001", "Brand Name", "new", "Ghana",
        "false", "physical", "SEO Title", "SEO Description", "tag1, tag2"
      ]
    end

    send_data csv_data,
              filename: "bulk_products_template_#{Date.current}.csv",
              type: "text/csv",
              disposition: "attachment"
  end

  private

  def require_seller
    unless current_user.seller.present?
      redirect_to new_seller_path, alert: "You need to create a seller account first"
    end
  end

  def set_product
    @product = current_user.seller.products.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to seller_products_path, alert: "Product not found or you don't have access"
  end

  def product_params
    params.require(:product).permit(
      :name, :description, :price, :original_price, :category_id,
      :stock_quantity, :sku, :published, :featured, :digital,
      :file_url, :preview_url, images: []
    )
  end

  def process_csv_upload(csv_file)
    results = { success: [], errors: [] }

    begin
      require "csv"
      csv_content = csv_file.read.force_encoding("UTF-8")
      csv = CSV.parse(csv_content, headers: true, skip_blanks: true)

      csv.each_with_index do |row, index|
        next if row["name"].blank?

        product = build_product_from_csv_row(row)

        if product.save
          results[:success] << product
        else
          results[:errors] << "Row #{index + 2}: #{row['name']} - #{product.errors.full_messages.join(', ')}"
        end
      end
    rescue CSV::MalformedCSVError => e
      results[:errors] << "Invalid CSV format: #{e.message}"
    rescue StandardError => e
      results[:errors] << "Error processing CSV: #{e.message}"
    end

    results
  end

  def build_product_from_csv_row(row)
    category = Category.find_by("LOWER(name) = ?", row["category_name"]&.downcase) || Category.first

    current_user.seller.products.build(
      name: row["name"],
      description: row["description"],
      price: row["price"].to_d,
      discounted_price: row["discounted_price"].presence&.to_d,
      category_id: category&.id,
      stock_quantity: row["stock_quantity"].to_i,
      sku: row["sku"].presence || generate_sku,
      barcode: generate_barcode,
      brand: row["brand"].presence || "Unbranded",
      condition: row["condition"].presence || "new",
      country_of_origin: row["country_of_origin"].presence || "Ghana",
      is_digital: row["is_digital"]&.downcase == "true",
      product_type: row["product_type"]&.downcase == "digital" ? 1 : 0,
      meta_title: row["meta_title"].presence || row["name"],
      meta_description: row["meta_description"].presence || row["description"]&.truncate(160),
      tags: row["tags"]&.split(",")&.map(&:strip) || [],
      published: false,
      status: "inactive"
    )
  end

  def process_bulk_form(products_params)
    results = { success: [], errors: [] }

    products_params.each_with_index do |(key, product_data), index|
      next if product_data[:name].blank?

      product = current_user.seller.products.build(
        name: product_data[:name],
        description: product_data[:description],
        price: product_data[:price].to_d,
        discounted_price: product_data[:discounted_price].presence&.to_d,
        category_id: product_data[:category_id],
        stock_quantity: product_data[:stock_quantity].to_i,
        sku: product_data[:sku].presence || generate_sku,
        barcode: generate_barcode,
        brand: product_data[:brand].presence || "Unbranded",
        condition: product_data[:condition].presence || "new",
        country_of_origin: product_data[:country_of_origin].presence || "Ghana",
        is_digital: product_data[:is_digital] == "1",
        product_type: product_data[:product_type].to_i,
        meta_title: product_data[:meta_title].presence || product_data[:name],
        meta_description: product_data[:meta_description].presence || product_data[:description]&.truncate(160),
        published: false,
        status: "inactive"
      )

      if product.save
        results[:success] << product
      else
        results[:errors] << "Product #{index + 1}: #{product_data[:name]} - #{product.errors.full_messages.join(', ')}"
      end
    end

    results
  end

  def generate_sku
    "SKU-#{SecureRandom.hex(4).upcase}"
  end

  def generate_barcode
    "BAR-#{SecureRandom.hex(6).upcase}"
  end
end
