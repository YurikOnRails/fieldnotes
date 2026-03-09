require "test_helper"

class Admin::BuildsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:admin) }

  test "index lists all builds" do
    get admin_builds_url
    assert_response :success
  end

  test "new renders form" do
    get new_admin_build_url
    assert_response :success
  end

  test "create with valid params" do
    assert_difference("Build.count", 1) do
      post admin_builds_url, params: { build: { title: "New Build", status: "active", kind: "oss" } }
    end
    assert_redirected_to edit_admin_build_url(Build.last)
  end

  test "create with invalid params renders 422" do
    post admin_builds_url, params: { build: { title: "" } }
    assert_response :unprocessable_entity
  end

  test "update changes build" do
    patch admin_build_url(builds(:first_position)), params: { build: { title: "Updated" } }
    assert_redirected_to edit_admin_build_url(builds(:first_position))
    assert_equal "Updated", builds(:first_position).reload.title
  end

  test "update with invalid params renders 422" do
    patch admin_build_url(builds(:first_position)), params: { build: { status: "invalid" } }
    assert_response :unprocessable_entity
  end

  test "destroy removes build" do
    assert_difference("Build.count", -1) do
      delete admin_build_url(builds(:first_position))
    end
    assert_redirected_to admin_builds_url
  end

  test "unauthenticated access redirects" do
    sign_out
    get admin_builds_url
    assert_redirected_to new_session_url
  end
end
