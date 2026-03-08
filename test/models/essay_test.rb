require "test_helper"

class EssayTest < ActiveSupport::TestCase
  # --- Валидации ---
  test "valid with all required attributes" do
    essay = Essay.new(title: "Test Essay", slug: "test-essay", status: "draft")
    assert essay.valid?
  end

  test "invalid without title" do
    essay = Essay.new(slug: "test", status: "draft")
    assert_not essay.valid?
    assert_includes essay.errors[:title], "can't be blank"
  end

  test "invalid without slug" do
    essay = Essay.new(title: "Test", status: "draft")
    assert_not essay.valid?
  end

  test "slug must be unique" do
    Essay.create!(title: "First", slug: "same-slug", status: "draft")
    duplicate = Essay.new(title: "Second", slug: "same-slug", status: "draft")
    assert_not duplicate.valid?
  end

  test "slug format allows only lowercase letters, numbers, hyphens" do
    essay = Essay.new(title: "Test", slug: "INVALID SLUG!", status: "draft")
    assert_not essay.valid?
  end

  test "status must be draft or published" do
    essay = Essay.new(title: "Test", slug: "test", status: "archived")
    assert_not essay.valid?
  end

  # --- Скоупы ---
  test "published scope returns only published essays ordered by published_at desc" do
    old = essays(:published_old)
    new_essay = essays(:published_new)
    _draft = essays(:draft)

    result = Essay.published
    assert_includes result, new_essay
    assert_includes result, old
    assert_not_includes result, _draft
    assert_equal new_essay, result.first
  end

  test "drafts scope returns only draft essays" do
    assert Essay.drafts.all? { it.status == "draft" }
  end

  # --- Методы ---
  test "published? returns true for published status" do
    essay = Essay.new(status: "published")
    assert essay.published?
  end

  test "draft? returns true for draft status" do
    essay = Essay.new(status: "draft")
    assert essay.draft?
  end
end
