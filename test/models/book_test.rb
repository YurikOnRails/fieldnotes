require "test_helper"

class BookTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    book = Book.new(title: "Clean Code", author: "Robert Martin", status: "completed")
    assert book.valid?
  end

  test "rating between 1 and 5" do
    book = Book.new(title: "X", author: "Y", status: "completed", rating: 6)
    assert_not book.valid?
  end

  test "rating can be nil" do
    book = Book.new(title: "X", author: "Y", status: "reading", rating: nil)
    assert book.valid?
  end

  test "status must be reading, completed, or abandoned" do
    book = Book.new(title: "X", author: "Y", status: "wishlist")
    assert_not book.valid?
  end

  test "completed scope returns only completed books" do
    assert Book.completed.all? { it.status == "completed" }
  end

  test "by_year scope orders by year_read desc" do
    years = Book.by_year.map(&:year_read).compact
    assert_equal years, years.sort.reverse
  end
end
