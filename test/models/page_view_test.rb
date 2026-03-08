require "test_helper"

class PageViewTest < ActiveSupport::TestCase
  test "valid with event name" do
    pv = PageView.new(event: "essay.viewed", payload: { essay_id: 1 })
    assert pv.valid?
  end

  test "invalid without event" do
    pv = PageView.new(payload: { essay_id: 1 })
    assert_not pv.valid?
  end

  test "payload stores JSON" do
    pv = PageView.create!(event: "essay.viewed", payload: { essay_id: 42, path: "/essays/test" })
    assert_equal 42, pv.reload.payload["essay_id"]
  end
end
