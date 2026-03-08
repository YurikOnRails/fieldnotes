require "test_helper"

class AnalyticsSubscriberTest < ActiveSupport::TestCase
  test "creates page_view on essay.viewed event" do
    assert_difference("PageView.count", 1) do
      Rails.event.notify("essay.viewed", essay_id: 1, path: "/essays/test")
    end
  end
end
