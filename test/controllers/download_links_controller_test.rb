require "test_helper"

class DownloadLinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @download_link = download_links(:one)
  end

  test "should get index" do
    get download_links_url
    assert_response :success
  end

  test "should get new" do
    get new_download_link_url
    assert_response :success
  end

  test "should create download_link" do
    assert_difference("DownloadLink.count") do
      post download_links_url, params: { download_link: { active: @download_link.active, download_count: @download_link.download_count, download_limit: @download_link.download_limit, expires_at: @download_link.expires_at, order_id: @download_link.order_id, product_id: @download_link.product_id, token: SecureRandom.urlsafe_base64, user_id: @download_link.user_id } }
    end

    assert_redirected_to download_link_url(DownloadLink.last)
  end

  test "should show download_link" do
    get download_link_url(@download_link)
    assert_response :success
  end

  test "should get edit" do
    get edit_download_link_url(@download_link)
    assert_response :success
  end

  test "should update download_link" do
    patch download_link_url(@download_link), params: { download_link: { active: @download_link.active, download_count: @download_link.download_count, download_limit: @download_link.download_limit, expires_at: @download_link.expires_at, order_id: @download_link.order_id, product_id: @download_link.product_id, token: @download_link.token, user_id: @download_link.user_id } }
    assert_redirected_to download_link_url(@download_link)
  end

  test "should destroy download_link" do
    assert_difference("DownloadLink.count", -1) do
      delete download_link_url(@download_link)
    end

    assert_redirected_to download_links_url
  end
end
