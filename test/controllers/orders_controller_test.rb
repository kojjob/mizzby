require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order = orders(:one)
  end

  test "should get index" do
    get orders_url
    assert_response :success
  end

  test "should get new" do
    get new_order_url
    assert_response :success
  end

  test "should create order" do
    assert_difference("Order.count") do
      post orders_url, params: { order: { notes: @order.notes, payment_details: @order.payment_details, payment_id: @order.payment_id, payment_processor: @order.payment_processor, payment_status: @order.payment_status, product_id: @order.product_id, status: @order.status, total_amount: @order.total_amount, user_id: @order.user_id } }
    end

    assert_redirected_to order_url(Order.last)
  end

  test "should show order" do
    get order_url(@order)
    assert_response :success
  end

  test "should get edit" do
    get edit_order_url(@order)
    assert_response :success
  end

  test "should update order" do
    patch order_url(@order), params: { order: { notes: @order.notes, payment_details: @order.payment_details, payment_id: @order.payment_id, payment_processor: @order.payment_processor, payment_status: @order.payment_status, product_id: @order.product_id, status: @order.status, total_amount: @order.total_amount, user_id: @order.user_id } }
    assert_redirected_to order_url(@order)
  end

  test "should destroy order" do
    assert_difference("Order.count", -1) do
      delete order_url(@order)
    end

    assert_redirected_to orders_url
  end
end
