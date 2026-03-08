require "test_helper"

class Admin::FieldControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:admin) }

  test "index lists all field series" do
    get admin_field_index_url
    assert_response :success
  end

  test "new renders form" do
    get new_admin_field_url
    assert_response :success
  end

  test "create with valid params" do
    assert_difference("FieldSeries.count", 1) do
      post admin_field_index_url, params: { field_series: { title: "New Series", slug: "new-series", kind: "photo" } }
    end
    assert_redirected_to admin_field_url(FieldSeries.last)
  end

  test "create with invalid params renders 422" do
    post admin_field_index_url, params: { field_series: { title: "" } }
    assert_response :unprocessable_entity
  end

  test "update changes field series" do
    patch admin_field_url(field_series(:iceland)), params: { field_series: { title: "Updated" } }
    assert_redirected_to admin_field_url(field_series(:iceland))
    assert_equal "Updated", field_series(:iceland).reload.title
  end

  test "update with invalid params renders 422" do
    patch admin_field_url(field_series(:iceland)), params: { field_series: { kind: "invalid" } }
    assert_response :unprocessable_entity
  end

  test "destroy removes field series" do
    assert_difference("FieldSeries.count", -1) do
      delete admin_field_url(field_series(:iceland))
    end
    assert_redirected_to admin_field_index_url
  end

  test "unauthenticated access redirects" do
    sign_out
    get admin_field_index_url
    assert_redirected_to new_session_url
  end
end
