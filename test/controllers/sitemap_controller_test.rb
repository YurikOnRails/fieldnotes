require "test_helper"

class SitemapControllerTest < ActionDispatch::IntegrationTest
  test "returns valid XML" do
    get sitemap_url(format: :xml)
    assert_response :success
    assert_equal "application/xml", response.media_type
    assert_includes response.body, essays(:published_new).slug
  end

  test "excludes drafts" do
    get sitemap_url(format: :xml)
    assert_not_includes response.body, essays(:draft).slug
  end
end
