require "test_helper"

class Public::FeedControllerTest < ActionDispatch::IntegrationTest
  test "index renders homepage" do
    get root_url
    assert_response :success
  end

  test "index.rss returns unified RSS feed" do
    get feed_url(format: :rss)
    assert_response :success
    assert_equal "application/rss+xml", response.media_type
  end
end
