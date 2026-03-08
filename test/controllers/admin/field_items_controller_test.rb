require "test_helper"

class Admin::FieldItemsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:admin) }

  test "create adds item to series" do
    assert_difference("FieldItem.count", 1) do
      post admin_field_field_items_url(field_series(:iceland)),
           params: { field_item: { kind: "photo", position: 10 } }
    end
    assert_response :redirect
  end

  test "update changes field item" do
    item = field_items(:photo_one)
    patch admin_field_field_item_url(field_series(:iceland), item),
          params: { field_item: { caption: "Updated caption" } }
    assert_response :redirect
    assert_equal "Updated caption", item.reload.caption
  end

  test "destroy removes field item" do
    assert_difference("FieldItem.count", -1) do
      delete admin_field_field_item_url(field_series(:iceland), field_items(:photo_one))
    end
    assert_response :redirect
  end

  test "unauthenticated access redirects" do
    sign_out
    post admin_field_field_items_url(field_series(:iceland)),
         params: { field_item: { kind: "photo", position: 99 } }
    assert_redirected_to new_session_url
  end
end
