require "test_helper"

class BuildTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    build = Build.new(title: "My Project", slug: "my-project", status: "active", kind: "oss")
    assert build.valid?
  end

  test "invalid without title" do
    build = Build.new(slug: "test", status: "active", kind: "oss")
    assert_not build.valid?
  end

  test "status must be in allowed list" do
    build = Build.new(title: "X", slug: "x", kind: "oss", status: "invalid")
    assert_not build.valid?
  end

  test "kind must be in allowed list" do
    build = Build.new(title: "X", slug: "x", status: "active", kind: "invalid")
    assert_not build.valid?
  end

  test "ordered scope returns by position" do
    positions = Build.ordered.map(&:position)
    assert_equal positions, positions.sort
  end

  test "active scope excludes archived" do
    assert Build.active.none? { it.status == "archived" }
  end
end
