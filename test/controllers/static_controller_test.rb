require "test_helper"

class StaticControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get static_home_url
    assert_response :success
  end

  test "should get contact" do
    get static_contact_url
    assert_response :success
  end

  test "should get about" do
    get static_about_url
    assert_response :success
  end

  test "should get help_center" do
    get static_help_center_url
    assert_response :success
  end

  test "should get privacy_policy" do
    get static_privacy_policy_url
    assert_response :success
  end

  test "should get term_of_service" do
    get static_term_of_service_url
    assert_response :success
  end
end
