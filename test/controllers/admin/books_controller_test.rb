require "test_helper"

class Admin::BooksControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:admin) }

  test "index lists all books" do
    get admin_books_url
    assert_response :success
  end

  test "new renders form" do
    get new_admin_book_url
    assert_response :success
  end

  test "create with valid params" do
    assert_difference("Book.count", 1) do
      post admin_books_url, params: { book: { title: "New Book", author: "Author", status: "reading" } }
    end
    assert_redirected_to edit_admin_book_url(Book.last)
  end

  test "create with invalid params renders 422" do
    post admin_books_url, params: { book: { title: "" } }
    assert_response :unprocessable_entity
  end

  test "update changes book" do
    patch admin_book_url(books(:completed_recent)), params: { book: { title: "Updated" } }
    assert_redirected_to edit_admin_book_url(books(:completed_recent))
    assert_equal "Updated", books(:completed_recent).reload.title
  end

  test "update with invalid params renders 422" do
    patch admin_book_url(books(:completed_recent)), params: { book: { rating: 10 } }
    assert_response :unprocessable_entity
  end

  test "destroy removes book" do
    assert_difference("Book.count", -1) do
      delete admin_book_url(books(:completed_recent))
    end
    assert_redirected_to admin_books_url
  end

  test "unauthenticated access redirects" do
    sign_out
    get admin_books_url
    assert_redirected_to new_session_url
  end
end
