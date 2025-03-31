require "test_helper"

class StaticControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get root_path
    assert_response :success
    assert_template 'static/home'
  end

  test "should get contact" do
    get contact_path
    assert_response :success
    assert_template 'static/contact'
  end

  test "should get about" do
    get about_path
    assert_response :success
    assert_template 'static/about'
  end

  test "should get help_center" do
    get help_center_path
    assert_response :success
    assert_template 'static/help_center'
  end

  test "should get privacy_policy" do
    get privacy_policy_path
    assert_response :success
    assert_template 'static/privacy_policy'
  end

  test "should get term_of_service" do
    get term_of_service_path
    assert_response :success
    assert_template 'static/term_of_service'
  end
end
