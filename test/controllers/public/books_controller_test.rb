require "test_helper"

class Public::BooksControllerTest < ActionDispatch::IntegrationTest
  test "index renders successfully" do
    get books_url
    assert_response :success
  end

  test "index shows completed books" do
    get books_url
    assert_match books(:completed_recent).title, response.body
  end

  test "show renders book detail page" do
    get book_url(books(:completed_recent))
    assert_response :success
    assert_match books(:completed_recent).title, response.body
    assert_match books(:completed_recent).author, response.body
  end
end
