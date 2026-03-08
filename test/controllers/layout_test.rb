require "test_helper"

class LayoutTest < ActionDispatch::IntegrationTest
  test "navigation contains required links" do
    get root_url
    assert_select "nav a", text: "Essays"
    assert_select "nav a", text: "Builds"
    assert_select "nav a", text: "Reading"
    assert_select "nav a", text: "Field"
    assert_select "nav a", text: "Now"
  end

  test "footer contains required links" do
    get root_url
    assert_select "footer a", text: "About"
    assert_select "footer a", text: "Uses"
    assert_select "footer a", text: "Contact"
    assert_select "footer a", text: "RSS"
  end
end
