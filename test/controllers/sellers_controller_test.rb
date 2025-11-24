require "test_helper"

class SellersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @seller = sellers(:one)
  end

  test "should get index" do
    get sellers_url
    assert_response :success
  end

  test "should get new" do
    get new_seller_url
    assert_response :success
  end

  test "should create seller" do
    assert_difference("Seller.count") do
      post sellers_url, params: { seller: { acceptance_rate: @seller.acceptance_rate, average_response_time: @seller.average_response_time, bank_account_details: @seller.bank_account_details, business_name: @seller.business_name, commission_rate: @seller.commission_rate, country: @seller.country, description: @seller.description, location: @seller.location, mobile_money_details: @seller.mobile_money_details, phone_number: @seller.phone_number, user_id: @seller.user_id, verified: @seller.verified } }
    end

    assert_redirected_to seller_url(Seller.last)
  end

  test "should show seller" do
    get seller_url(@seller)
    assert_response :success
  end

  test "should get edit" do
    get edit_seller_url(@seller)
    assert_response :success
  end

  test "should update seller" do
    patch seller_url(@seller), params: { seller: { acceptance_rate: @seller.acceptance_rate, average_response_time: @seller.average_response_time, bank_account_details: @seller.bank_account_details, business_name: @seller.business_name, commission_rate: @seller.commission_rate, country: @seller.country, description: @seller.description, location: @seller.location, mobile_money_details: @seller.mobile_money_details, phone_number: @seller.phone_number, user_id: @seller.user_id, verified: @seller.verified } }
    assert_redirected_to seller_url(@seller)
  end

  test "should destroy seller" do
    assert_difference("Seller.count", -1) do
      delete seller_url(@seller)
    end

    assert_redirected_to sellers_url
  end
end
