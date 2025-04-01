require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
  end

  test "should get index" do
    get products_url
    assert_response :success
  end

  test "should get new" do
    get new_product_url
    assert_response :success
  end

  test "should create product" do
    assert_difference("Product.count") do
      post products_url, params: { product: { available_in_ghana: @product.available_in_ghana, available_in_nigeria: @product.available_in_nigeria, barcode: @product.barcode, brand: @product.brand, category_id: @product.category_id, condition: @product.condition, country_of_origin: @product.country_of_origin, currency: @product.currency, description: @product.description, dimensions: @product.dimensions, discounted_price: @product.discounted_price, featured: @product.featured, is_digital: @product.is_digital, meta_description: @product.meta_description, meta_title: @product.meta_title, name: @product.name, price: @product.price, published: @product.published, published_at: @product.published_at, seller_id: @product.seller_id, shipping_time: @product.shipping_time, sku: @product.sku, status: @product.status, stock_quantity: @product.stock_quantity, weight: @product.weight } }
    end

    assert_redirected_to product_url(Product.last)
  end

  test "should show product" do
    get product_url(@product)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_url(@product)
    assert_response :success
  end

  test "should update product" do
    patch product_url(@product), params: { product: { available_in_ghana: @product.available_in_ghana, available_in_nigeria: @product.available_in_nigeria, barcode: @product.barcode, brand: @product.brand, category_id: @product.category_id, condition: @product.condition, country_of_origin: @product.country_of_origin, currency: @product.currency, description: @product.description, dimensions: @product.dimensions, discounted_price: @product.discounted_price, featured: @product.featured, is_digital: @product.is_digital, meta_description: @product.meta_description, meta_title: @product.meta_title, name: @product.name, price: @product.price, published: @product.published, published_at: @product.published_at, seller_id: @product.seller_id, shipping_time: @product.shipping_time, sku: @product.sku, status: @product.status, stock_quantity: @product.stock_quantity, weight: @product.weight } }
    assert_redirected_to product_url(@product)
  end

  test "should destroy product" do
    assert_difference("Product.count", -1) do
      delete product_url(@product)
    end

    assert_redirected_to products_url
  end
end
