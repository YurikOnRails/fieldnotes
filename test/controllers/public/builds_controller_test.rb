require "test_helper"

class Public::BuildsControllerTest < ActionDispatch::IntegrationTest
  test "index renders successfully" do
    get builds_url
    assert_response :success
  end

  test "index shows only non-archived builds" do
    get builds_url
    assert_no_match builds(:archived_build).title, response.body
  end
end
