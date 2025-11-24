require "test_helper"

class SignInDebugTest < ActionDispatch::IntegrationTest
  test "sign in works" do
    user = users(:seller)
    puts "User valid? #{user.valid?}"
    puts "User errors: #{user.errors.full_messages}" unless user.valid?
    
    sign_in user
    
    # Try to access a protected page
    get new_seller_url
    puts "Response: #{response.status}"
    if response.redirect?
      puts "Redirected to: #{response.redirect_url}"
    end
    
    assert_response :success
  end
end
