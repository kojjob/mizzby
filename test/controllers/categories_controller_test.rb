require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = categories(:one)
  end

  test "should get index" do
    get categories_url
    assert_response :success
  end

  test "should get new" do
    get new_category_url
    assert_response :success
  end

  test "should create category" do
    assert_difference("Category.count") do
      post categories_url, params: { category: { 
        description: "A new test category description", 
        icon_color: "#FF5733", 
        icon_name: "new-icon", 
        name: "New Test Category", 
        parent_id: nil, 
        position: 10, 
        slug: "new-test-category-#{SecureRandom.hex(4)}", 
        visible: true 
      } }
    end

    assert_redirected_to category_url(Category.last)
  end

  test "should show category" do
    get category_url(@category)
    assert_response :success
  end

  test "should get edit" do
    get edit_category_url(@category)
    assert_response :success
  end

  test "should update category" do
    patch category_url(@category), params: { category: { description: @category.description, icon_color: @category.icon_color, icon_name: @category.icon_name, name: @category.name, parent_id: @category.parent_id, position: @category.position, slug: @category.slug, visible: @category.visible } }
    assert_redirected_to category_url(@category)
  end

  test "should destroy category" do
    # Create a category without products for deletion
    category_to_delete = Category.create!(
      name: "Deletable Category",
      slug: "deletable-category-#{SecureRandom.hex(4)}",
      description: "A category for testing deletion"
    )

    assert_difference("Category.count", -1) do
      delete category_url(category_to_delete)
    end

    assert_redirected_to categories_url
  end
end
