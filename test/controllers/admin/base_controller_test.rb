require "test_helper"

class Admin::BaseControllerTest < ActionDispatch::IntegrationTest
  test "redirects unauthenticated user to login" do
    get admin_root_url
    assert_redirected_to new_session_url
  end

  test "allows authenticated user" do
    sign_in_as users(:admin)
    get admin_root_url
    assert_response :success
  end
end
