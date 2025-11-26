require "test_helper"

class WishlistItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular_user)  # Use the user who owns the wishlist item
    @wishlist_item = wishlist_items(:one)
    sign_in @user
  end

  test "should get index" do
    get wishlist_items_url
    assert_response :success
  end

  test "should get new" do
    get new_wishlist_item_url
    assert_response :success
  end

  test "should create wishlist_item" do
    # Use a product that isn't already in the user's wishlist
    assert_difference("WishlistItem.count") do
      post wishlist_items_url, params: { wishlist_item: { notes: "Adding to my wishlist", product_id: products(:two).id } }
    end

    # Controller redirects back to products_path on success
    assert_redirected_to products_path
  end

  test "should show wishlist_item" do
    get wishlist_item_url(@wishlist_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_wishlist_item_url(@wishlist_item)
    assert_response :success
  end

  test "should update wishlist_item" do
    patch wishlist_item_url(@wishlist_item), params: { wishlist_item: { notes: "Updated notes", product_id: @wishlist_item.product_id } }
    assert_redirected_to wishlist_item_url(@wishlist_item)
  end

  test "should destroy wishlist_item" do
    assert_difference("WishlistItem.count", -1) do
      delete wishlist_item_url(@wishlist_item)
    end

    assert_redirected_to wishlist_items_url
  end
end
