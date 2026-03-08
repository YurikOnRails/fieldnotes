require "test_helper"

class Admin::NowControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:admin) }

  test "edit renders form" do
    get edit_admin_now_url
    assert_response :success
  end

  test "update creates new now entry" do
    assert_difference("NowEntry.count", 1) do
      patch admin_now_url, params: { now_entry: { body: "What I'm doing now" } }
    end
    assert_redirected_to edit_admin_now_url
  end

  test "unauthenticated access redirects" do
    sign_out
    get edit_admin_now_url
    assert_redirected_to new_session_url
  end
end
