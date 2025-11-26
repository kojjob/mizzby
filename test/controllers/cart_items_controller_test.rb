require "test_helper"

class CartItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cart_item = cart_items(:one)
    @user = users(:regular_user)
    sign_in @user
  end

  test "should get index" do
    get cart_items_url
    assert_response :success
  end

  test "should get new" do
    get new_cart_item_url
    assert_response :success
  end

  test "should create cart_item" do
    # Use product two which isn't already in cart one
    assert_difference("CartItem.count") do
      post cart_items_url, params: { cart_item: { cart_id: carts(:one).id, price: 19.99, product_id: products(:two).id, quantity: 1 } }
    end

    assert_redirected_to cart_item_url(CartItem.last)
  end

  test "should show cart_item" do
    get cart_item_url(@cart_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_cart_item_url(@cart_item)
    assert_response :success
  end

  test "should update cart_item" do
    patch cart_item_url(@cart_item), params: { cart_item: { cart_id: @cart_item.cart_id, price: @cart_item.price, product_id: @cart_item.product_id, quantity: 2 } }
    assert_redirected_to cart_item_url(@cart_item)
  end

  test "should destroy cart_item" do
    assert_difference("CartItem.count", -1) do
      delete cart_item_url(@cart_item)
    end

    assert_redirected_to cart_items_url
  end
end
