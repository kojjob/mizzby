require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: "test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      first_name: "Test",
      last_name: "User"
    )
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end

  test "email should be unique" do
    # Use fixture user which is already saved
    existing_user = users(:regular_user)
    duplicate_user = User.new(
      email: existing_user.email,
      password: "Password123!",
      password_confirmation: "Password123!",
      first_name: "Duplicate",
      last_name: "User"
    )
    assert_not duplicate_user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[newuser@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "password should be present" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "first_name should be present" do
    @user.first_name = "     "
    assert_not @user.valid?
  end

  test "last_name should be present" do
    @user.last_name = "     "
    assert_not @user.valid?
  end

  test "full_name returns correctly formatted name" do
    assert_equal "Test User", @user.full_name

    @user.first_name = nil
    @user.last_name = "Only"
    assert_equal "Only", @user.full_name

    @user.first_name = "First"
    @user.last_name = nil
    assert_equal "First", @user.full_name

    @user.first_name = nil
    @user.last_name = nil
    assert_equal "test", @user.full_name # Should return first part of email
  end

  test "initials returns correct values" do
    assert_equal "TU", @user.initials

    @user.first_name = nil
    @user.last_name = "Only"
    assert_equal "O", @user.initials

    @user.first_name = "First"
    @user.last_name = nil
    assert_equal "F", @user.initials

    @user.first_name = nil
    @user.last_name = nil
    assert_equal "T", @user.initials # Should return first character of email
  end

  test "can_manage? works for admins and owners" do
    # Use fixture users which are already saved
    user = users(:regular_user)
    other_user = users(:seller)

    # Create product, review, and order with associations
    seller = Seller.create!(user: user, business_name: "Test Seller")
    product = Product.new(seller: seller)
    review = Review.new(user_id: user.id)
    order = Order.new(user_id: user.id)

    # Admin can manage all resources
    user.admin = true
    assert user.can_manage?(product)
    assert user.can_manage?(review)
    assert user.can_manage?(order)

    # Non-admin can only manage their own resources
    user.admin = false
    assert user.can_manage?(review)
    assert user.can_manage?(order)

    # Test non-owners - use user_id to ensure proper association
    other_user_review = Review.new(user_id: other_user.id)
    other_user_order = Order.new(user_id: other_user.id)

    assert_not user.can_manage?(other_user_review)
    assert_not user.can_manage?(other_user_order)
  end

  test "default preferences are set for new users" do
    assert_equal "light", @user.theme
    assert_equal true, @user.email_notifications
    assert_equal false, @user.marketing_emails
    assert_equal false, @user.two_factor_enabled
    assert_equal "USD", @user.currency_preference
    assert_equal "en", @user.language_preference
  end

  test "seller? returns correct value" do
    # Use fixture users
    regular_user = users(:regular_user)
    seller_user = users(:seller)

    # Regular user without seller profile should not be seller
    regular_user.seller&.destroy
    regular_user.reload
    assert_not regular_user.seller?

    # Seller user with seller profile should be seller
    assert seller_user.seller?
  end

  test "admin? returns correct value for admins" do
    assert_not @user.admin?

    @user.admin = true
    assert @user.admin?
  end

  test "admin? returns correct value for super_admins" do
    assert_not @user.admin?

    @user.super_admin = true
    assert @user.admin?
  end

  test "super_admin? returns correct value" do
    assert_not @user.super_admin?

    @user.super_admin = true
    assert @user.super_admin?
  end

  test "completed_profile? returns correct value" do
    assert_not @user.completed_profile? # No profile picture

    # Test with mock attachment - since we can't easily attach a file in a unit test
    # We'll mock the attachment check
    def @user.profile_picture_attached?
      true
    end

    assert @user.completed_profile?

    @user.first_name = nil
    assert_not @user.completed_profile?

    @user.first_name = "Test"
    @user.last_name = nil
    assert_not @user.completed_profile?
  end
end
