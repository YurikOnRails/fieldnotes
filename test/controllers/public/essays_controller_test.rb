require "test_helper"

class Public::EssaysControllerTest < ActionDispatch::IntegrationTest
  test "index shows published essays only" do
    get essays_url
    assert_response :success
    assert_select "article", count: Essay.published.count
  end

  test "index does not show drafts" do
    get essays_url
    assert_no_match essays(:draft).title, response.body
  end

  test "show renders published essay" do
    essay = essays(:published_new)
    get essay_url(slug: essay.slug)
    assert_response :success
  end

  test "show returns 404 for draft" do
    get essay_url(slug: essays(:draft).slug)
    assert_response :not_found
  end

  test "show.rss returns RSS format" do
    essay = essays(:published_new)
    get essay_url(slug: essay.slug, format: :rss)
    assert_response :success
    assert_equal "application/rss+xml", response.media_type
  end

  test "show.md returns markdown" do
    essay = essays(:published_new)
    get essay_url(slug: essay.slug, format: :md)
    assert_response :success
    assert_equal "text/markdown", response.media_type
  end

  test "emits essay.viewed event" do
    essay = essays(:published_new)
    assert_difference("PageView.count", 1) do
      get essay_url(slug: essay.slug)
    end
  end

  test "returns 304 when not modified" do
    essay = essays(:published_new)
    get essay_url(slug: essay.slug)
    etag = response.headers["ETag"]

    get essay_url(slug: essay.slug), headers: { "If-None-Match" => etag }
    assert_response :not_modified
  end
end
