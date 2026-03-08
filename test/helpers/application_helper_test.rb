require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "meta_tags renders og:title" do
    result = meta_tags(title: "My Essay", description: "About Rails")
    assert_match "og:title", result
  end

  test "meta_tags renders description" do
    result = meta_tags(title: "My Essay", description: "About Rails")
    assert_match "About Rails", result
  end

  test "meta_tags renders JSON-LD for article type" do
    result = meta_tags(title: "Essay", description: "Desc", type: :article, published_at: Time.current)
    assert_match '"@type":"Article"', result
  end

  test "picture_tag returns empty string when not attached" do
    attachment = essays(:draft).cover
    assert_equal "", picture_tag(attachment, alt: "test")
  end
end
