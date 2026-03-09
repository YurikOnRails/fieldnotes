require "test_helper"

class EssayTest < ActiveSupport::TestCase
  # --- Validations ---
  test "valid with all required attributes" do
    essay = Essay.new(title: "Test Essay", slug: "test-essay", status: "draft")
    assert essay.valid?
  end

  test "invalid without title" do
    essay = Essay.new(slug: "test", status: "draft")
    assert_not essay.valid?
    assert_includes essay.errors[:title], "can't be blank"
  end

  test "status must be draft or published" do
    essay = Essay.new(title: "Test", slug: "test", status: "archived")
    assert_not essay.valid?
  end

  # --- Slug auto-generation ---
  test "auto-generates slug from title on create" do
    essay = Essay.new(title: "My Great Post", status: "draft")
    essay.valid?
    assert_equal "my-great-post", essay.slug
  end

  test "appends suffix for duplicate slugs" do
    Essay.create!(title: "Hello World", status: "draft")
    second = Essay.create!(title: "Hello World", status: "draft")
    assert_equal "hello-world-2", second.slug
  end

  test "increments suffix until unique" do
    Essay.create!(title: "Duplicate", status: "draft")
    Essay.create!(title: "Duplicate", slug: "duplicate-2", status: "draft")
    third = Essay.create!(title: "Duplicate", status: "draft")
    assert_equal "duplicate-3", third.slug
  end

  test "does not overwrite explicit slug" do
    essay = Essay.new(title: "Test", slug: "custom-slug", status: "draft")
    essay.valid?
    assert_equal "custom-slug", essay.slug
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

  # --- Auto published_at ---
  test "sets published_at when publishing without date" do
    essay = Essay.create!(title: "Test", status: "draft")
    assert_nil essay.published_at

    essay.update!(status: "published")
    assert_not_nil essay.published_at
  end

  test "does not overwrite explicit published_at" do
    date = Time.new(2026, 1, 15, 12, 0, 0)
    essay = Essay.create!(title: "Test", status: "published", published_at: date)
    assert_equal date, essay.published_at
  end

  test "does not change published_at on subsequent saves" do
    essay = Essay.create!(title: "Test", status: "published")
    original_date = essay.published_at

    essay.update!(title: "Updated Title")
    assert_equal original_date, essay.reload.published_at
  end

  # --- Scopes ---
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

  test "published scope excludes drafts" do
    assert Essay.published.none? { it.status == "draft" }
  end

  # --- Methods ---
  test "published? returns true for published status" do
    essay = Essay.new(status: "published")
    assert essay.published?
  end

  test "draft? returns true for draft status" do
    essay = Essay.new(status: "draft")
    assert essay.draft?
  end
end
