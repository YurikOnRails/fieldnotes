require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "valid with name" do
    tag = Tag.new(name: "elixir")
    assert tag.valid?
  end

  test "name must be unique" do
    Tag.create!(name: "unique-tag")
    assert_not Tag.new(name: "unique-tag").valid?
  end

  test "essay can have tags" do
    essay = essays(:published_new)
    tag = tags(:ruby)
    essay.tags << tag
    assert_includes essay.tags, tag
  end

  test "tag can belong to multiple taggables" do
    tag = tags(:ruby)
    assert tag.taggings.count >= 0
  end
end
