require "test_helper"

class Public::NowControllerTest < ActionDispatch::IntegrationTest
  test "show renders latest now entry" do
    get now_url
    assert_response :success
  end

  test "show displays previous entries" do
    get now_url
    assert_select ".previous-entries"
  end
end
