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

  # --- Cover image URL ---
  test "cover_image_url returns cover_url when present" do
    book = Book.new(cover_url: "https://example.com/cover.jpg")
    assert_equal "https://example.com/cover.jpg", book.cover_image_url
  end

  test "cover_image_url falls back to Open Library by ISBN" do
    book = Book.new(isbn: "9780134757599")
    assert_includes book.cover_image_url, "9780134757599"
  end

  test "cover_image_url returns nil without cover_url or isbn" do
    book = Book.new
    assert_nil book.cover_image_url
  end

  # --- ISBN auto-fetch ---
  test "fetches metadata from ISBN on create" do
    fake_data = { title: "Refactoring", author: "Martin Fowler", cover_url: "https://covers.openlibrary.org/b/isbn/9780134757599-L.jpg" }

    original = OpenLibraryService.method(:fetch)
    OpenLibraryService.define_singleton_method(:fetch) { |isbn:, **| fake_data }

    book = Book.new(isbn: "9780134757599", status: "reading")
    book.valid?

    assert_equal "Refactoring", book.title
    assert_equal "Martin Fowler", book.author
  ensure
    OpenLibraryService.define_singleton_method(:fetch, original)
  end

  test "does not overwrite existing title with ISBN fetch" do
    book = Book.new(isbn: "9780134757599", title: "My Custom Title", author: "Someone", status: "reading")
    # Even if fetch would return data, existing title is preserved
    # (fetch only runs on create and only fills blank fields)
    book.valid?
    assert_equal "My Custom Title", book.title
  end

  test "handles nil from API gracefully" do
    book = Book.new(isbn: "0000000000", title: "Manual Entry", author: "Someone", status: "reading")
    # OpenLibraryService.fetch returns nil for unknown ISBNs (cached or API failure)
    # Book should still be valid with manually provided title/author
    assert book.valid?
    assert_equal "Manual Entry", book.title
  end
end
