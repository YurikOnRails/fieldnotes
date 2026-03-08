require "test_helper"

class Public::FieldControllerTest < ActionDispatch::IntegrationTest
  test "index renders successfully" do
    get field_index_url
    assert_response :success
  end

  test "show renders field series" do
    series = field_series(:iceland)
    get field_url(slug: series.slug)
    assert_response :success
  end

  test "emits field.viewed event" do
    series = field_series(:iceland)
    assert_difference("PageView.count", 1) do
      get field_url(slug: series.slug)
    end
  end
end
