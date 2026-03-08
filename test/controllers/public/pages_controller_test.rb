require "test_helper"

class Public::PagesControllerTest < ActionDispatch::IntegrationTest
  test "about renders successfully" do
    get about_url
    assert_response :success
  end

  test "contact renders successfully" do
    get contact_url
    assert_response :success
  end

  test "uses renders successfully" do
    get uses_url
    assert_response :success
  end
end
