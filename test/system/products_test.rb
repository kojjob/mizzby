require "application_system_test_case"

class ProductsTest < ApplicationSystemTestCase
  setup do
    @product = products(:one)
  end

  test "visiting the index" do
    visit products_url
    assert_selector "h1", text: "Products"
  end

  test "should create product" do
    visit products_url
    click_on "New product"

    check "Available in ghana" if @product.available_in_ghana
    check "Available in nigeria" if @product.available_in_nigeria
    fill_in "Barcode", with: @product.barcode
    fill_in "Brand", with: @product.brand
    fill_in "Category", with: @product.category_id
    fill_in "Condition", with: @product.condition
    fill_in "Country of origin", with: @product.country_of_origin
    fill_in "Currency", with: @product.currency
    fill_in "Description", with: @product.description
    fill_in "Dimensions", with: @product.dimensions
    fill_in "Discounted price", with: @product.discounted_price
    check "Featured" if @product.featured
    check "Is digital" if @product.is_digital
    fill_in "Meta description", with: @product.meta_description
    fill_in "Meta title", with: @product.meta_title
    fill_in "Name", with: @product.name
    fill_in "Price", with: @product.price
    check "Published" if @product.published
    fill_in "Published at", with: @product.published_at
    fill_in "Seller", with: @product.seller_id
    fill_in "Shipping time", with: @product.shipping_time
    fill_in "Sku", with: @product.sku
    fill_in "Status", with: @product.status
    fill_in "Stock quantity", with: @product.stock_quantity
    fill_in "Weight", with: @product.weight
    click_on "Create Product"

    assert_text "Product was successfully created"
    click_on "Back"
  end

  test "should update Product" do
    visit product_url(@product)
    click_on "Edit this product", match: :first

    check "Available in ghana" if @product.available_in_ghana
    check "Available in nigeria" if @product.available_in_nigeria
    fill_in "Barcode", with: @product.barcode
    fill_in "Brand", with: @product.brand
    fill_in "Category", with: @product.category_id
    fill_in "Condition", with: @product.condition
    fill_in "Country of origin", with: @product.country_of_origin
    fill_in "Currency", with: @product.currency
    fill_in "Description", with: @product.description
    fill_in "Dimensions", with: @product.dimensions
    fill_in "Discounted price", with: @product.discounted_price
    check "Featured" if @product.featured
    check "Is digital" if @product.is_digital
    fill_in "Meta description", with: @product.meta_description
    fill_in "Meta title", with: @product.meta_title
    fill_in "Name", with: @product.name
    fill_in "Price", with: @product.price
    check "Published" if @product.published
    fill_in "Published at", with: @product.published_at.to_s
    fill_in "Seller", with: @product.seller_id
    fill_in "Shipping time", with: @product.shipping_time
    fill_in "Sku", with: @product.sku
    fill_in "Status", with: @product.status
    fill_in "Stock quantity", with: @product.stock_quantity
    fill_in "Weight", with: @product.weight
    click_on "Update Product"

    assert_text "Product was successfully updated"
    click_on "Back"
  end

  test "should destroy Product" do
    visit product_url(@product)
    accept_confirm { click_on "Destroy this product", match: :first }

    assert_text "Product was successfully destroyed"
  end
end
