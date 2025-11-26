require "test_helper"

class SellersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @seller = sellers(:seller_profile)
    @user = users(:seller)
    sign_in @user
  end

  test "should show seller" do
    get seller_url(@seller)
    assert_response :success
  end

  test "should get edit for own seller profile" do
    get edit_seller_url(@seller)
    assert_response :success
  end

  test "should update own seller profile" do
    patch seller_url(@seller), params: {
      seller: {
        business_name: "Updated Business Name",
        description: @seller.description,
        location: @seller.location,
        country: @seller.country,
        phone_number: @seller.phone_number,
        bank_account_details: @seller.bank_account_details,
        mobile_money_details: @seller.mobile_money_details
      }
    }
    # Controller redirects to dashboard_sellers_path after update
    assert_redirected_to dashboard_sellers_path
  end

  test "should redirect to dashboard if user already has seller account" do
    get new_seller_url
    assert_redirected_to dashboard_sellers_path
  end
end

class SellersControllerNewUserTest < ActionDispatch::IntegrationTest
  setup do
    # Use a user without a seller profile
    @user_without_seller = users(:unconfirmed)
    # Confirm the user so they can sign in
    @user_without_seller.update!(confirmed_at: Time.current)
    sign_in @user_without_seller
  end

  test "should get new for user without seller profile" do
    get new_seller_url
    assert_response :success
  end

  test "should create seller for user without seller profile" do
    assert_difference("Seller.count") do
      post sellers_url, params: {
        seller: {
          business_name: "New Test Business",
          description: "A new test seller",
          location: "Test Location",
          country: "Ghana",
          phone_number: "+233555555555",
          bank_account_details: "Test Bank",
          mobile_money_details: "Test Mobile Money"
        }
      }
    end

    # Controller redirects to dashboard after creation
    assert_redirected_to dashboard_sellers_path
  end
end
