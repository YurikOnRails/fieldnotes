require "test_helper"

class Admin::EssaysControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:admin) }

  test "index lists all essays" do
    get admin_essays_url
    assert_response :success
  end

  test "new renders form" do
    get new_admin_essay_url
    assert_response :success
  end

  test "create with valid params" do
    assert_difference("Essay.count", 1) do
      post admin_essays_url, params: { essay: { title: "New Essay", status: "draft" } }
    end
    assert_redirected_to edit_admin_essay_url(Essay.last)
  end

  test "create with invalid params renders 422" do
    post admin_essays_url, params: { essay: { title: "", slug: "" } }
    assert_response :unprocessable_entity
  end

  test "edit renders form" do
    get edit_admin_essay_url(essays(:draft))
    assert_response :success
  end

  test "update changes essay" do
    patch admin_essay_url(essays(:draft)), params: { essay: { title: "Updated" } }
    assert_redirected_to edit_admin_essay_url(essays(:draft))
    assert_equal "Updated", essays(:draft).reload.title
  end

  test "update with invalid params renders 422" do
    patch admin_essay_url(essays(:draft)), params: { essay: { title: "", slug: "" } }
    assert_response :unprocessable_entity
  end

  test "destroy removes essay" do
    assert_difference("Essay.count", -1) do
      delete admin_essay_url(essays(:draft))
    end
    assert_redirected_to admin_essays_url
  end

  test "unauthenticated access redirects" do
    sign_out
    get admin_essays_url
    assert_redirected_to new_session_url
  end
end
