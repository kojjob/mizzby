require "application_system_test_case"

class ProductImagesTest < ApplicationSystemTestCase
  setup do
    @product_image = product_images(:one)
  end

  test "visiting the index" do
    visit product_images_url
    assert_selector "h1", text: "Product images"
  end

  test "should create product image" do
    visit product_images_url
    click_on "New product image"

    fill_in "Alt text", with: @product_image.alt_text
    fill_in "Position", with: @product_image.position
    fill_in "Product", with: @product_image.product_id
    click_on "Create Product image"

    assert_text "Product image was successfully created"
    click_on "Back"
  end

  test "should update Product image" do
    visit product_image_url(@product_image)
    click_on "Edit this product image", match: :first

    fill_in "Alt text", with: @product_image.alt_text
    fill_in "Position", with: @product_image.position
    fill_in "Product", with: @product_image.product_id
    click_on "Update Product image"

    assert_text "Product image was successfully updated"
    click_on "Back"
  end

  test "should destroy Product image" do
    visit product_image_url(@product_image)
    accept_confirm { click_on "Destroy this product image", match: :first }

    assert_text "Product image was successfully destroyed"
  end
end
