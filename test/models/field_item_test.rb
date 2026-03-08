require "test_helper"

class FieldItemTest < ActiveSupport::TestCase
  test "valid photo item" do
    item = FieldItem.new(field_series: field_series(:iceland), kind: "photo", position: 99)
    assert item.valid?
  end

  test "video item requires youtube_url" do
    item = FieldItem.new(field_series: field_series(:iceland), kind: "video", position: 99, youtube_url: nil)
    assert_not item.valid?
  end

  test "ordered scope sorts by position" do
    positions = FieldItem.ordered.map(&:position)
    assert_equal positions, positions.sort
  end
end
