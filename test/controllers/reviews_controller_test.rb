require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @review = reviews(:one)
    @user = users(:seller)  # Use a different user who hasn't reviewed product one
    sign_in @user
  end

  test "should get index" do
    get reviews_url
    assert_response :success
  end

  test "should get new" do
    get new_review_url
    assert_response :success
  end

  test "should create review" do
    # Use a user/product combo that doesn't exist yet
    assert_difference("Review.count") do
      post reviews_url, params: { review: { content: "This is an excellent product review with detailed information!", product_id: products(:one).id, published: true, rating: 5, user_id: @user.id } }
    end

    assert_redirected_to review_url(Review.last)
  end

  test "should show review" do
    get review_url(@review)
    assert_response :success
  end

  test "should get edit" do
    get edit_review_url(@review)
    assert_response :success
  end

  test "should update review" do
    patch review_url(@review), params: { review: { content: "Updated review content with enough characters for validation.", product_id: @review.product_id, published: @review.published, rating: @review.rating, user_id: @review.user_id } }
    assert_redirected_to review_url(@review)
  end

  test "should destroy review" do
    assert_difference("Review.count", -1) do
      delete review_url(@review)
    end

    assert_redirected_to reviews_url
  end
end
