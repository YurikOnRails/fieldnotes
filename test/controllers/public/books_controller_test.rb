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
end
