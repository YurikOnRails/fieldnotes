require "test_helper"

class AnalyticsSubscriberTest < ActiveSupport::TestCase
  test "creates page_view on essay.viewed event" do
    assert_difference("PageView.count", 1) do
      Rails.event.notify("essay.viewed", essay_id: 1, path: "/essays/test")
    end
  end

  test "creates page_view on field.viewed event" do
    assert_difference("PageView.count", 1) do
      Rails.event.notify("field.viewed", series_id: 1, path: "/field/iceland-2026")
    end
  end

  test "ignores untracked events" do
    assert_no_difference("PageView.count") do
      Rails.event.notify("some.other.event", foo: "bar")
    end
  end
end
