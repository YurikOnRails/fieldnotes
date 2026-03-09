require "test_helper"

class FieldSeriesTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    series = FieldSeries.new(title: "Patagonia 2026", slug: "patagonia-2026", kind: "photo")
    assert series.valid?
  end

  test "kind must be photo, video, or mixed" do
    series = FieldSeries.new(title: "X", slug: "x", kind: "audio")
    assert_not series.valid?
  end

  test "has many field_items" do
    series = field_series(:iceland)
    assert series.field_items.any?
  end

  test "destroying series destroys items" do
    series = field_series(:iceland)
    item_count = series.field_items.count
    assert_difference("FieldItem.count", -item_count) { series.destroy }
  end

  # --- Slug auto-generation ---
  test "auto-generates slug from title" do
    series = FieldSeries.new(title: "Japan 2026", kind: "photo")
    series.valid?
    assert_equal "japan-2026", series.slug
  end

  test "handles duplicate slugs for series" do
    FieldSeries.create!(title: "Mountains", kind: "photo")
    second = FieldSeries.create!(title: "Mountains", kind: "video")
    assert_equal "mountains-2", second.slug
  end
end
