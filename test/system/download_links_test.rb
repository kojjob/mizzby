require "application_system_test_case"

class DownloadLinksTest < ApplicationSystemTestCase
  setup do
    @download_link = download_links(:one)
  end

  test "visiting the index" do
    visit download_links_url
    assert_selector "h1", text: "Download links"
  end

  test "should create download link" do
    visit download_links_url
    click_on "New download link"

    check "Active" if @download_link.active
    fill_in "Download count", with: @download_link.download_count
    fill_in "Download limit", with: @download_link.download_limit
    fill_in "Expires at", with: @download_link.expires_at
    fill_in "Order", with: @download_link.order_id
    fill_in "Product", with: @download_link.product_id
    fill_in "Token", with: @download_link.token
    fill_in "User", with: @download_link.user_id
    click_on "Create Download link"

    assert_text "Download link was successfully created"
    click_on "Back"
  end

  test "should update Download link" do
    visit download_link_url(@download_link)
    click_on "Edit this download link", match: :first

    check "Active" if @download_link.active
    fill_in "Download count", with: @download_link.download_count
    fill_in "Download limit", with: @download_link.download_limit
    fill_in "Expires at", with: @download_link.expires_at.to_s
    fill_in "Order", with: @download_link.order_id
    fill_in "Product", with: @download_link.product_id
    fill_in "Token", with: @download_link.token
    fill_in "User", with: @download_link.user_id
    click_on "Update Download link"

    assert_text "Download link was successfully updated"
    click_on "Back"
  end

  test "should destroy Download link" do
    visit download_link_url(@download_link)
    accept_confirm { click_on "Destroy this download link", match: :first }

    assert_text "Download link was successfully destroyed"
  end
end
