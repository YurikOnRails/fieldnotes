require "test_helper"

class NowEntryTest < ActiveSupport::TestCase
  test "valid with published_at" do
    entry = NowEntry.new(published_at: Time.current)
    assert entry.valid?
  end

  test "invalid without published_at" do
    entry = NowEntry.new
    assert_not entry.valid?
  end

  test "has rich text body" do
    entry = now_entries(:current)
    assert_respond_to entry, :body
  end

  test "latest scope returns most recent entry" do
    assert_equal now_entries(:current), NowEntry.latest
  end

  test "previous scope returns older entries ordered by published_at desc" do
    result = NowEntry.previous
    assert_not_includes result, now_entries(:current)
    assert result.all? { it.published_at < now_entries(:current).published_at }
  end
end
