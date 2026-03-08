class Public::BooksController < Public::BaseController
  rate_limit to: 60, within: 1.minute

  def index
    @books = Book.by_year
    fresh_when @books
  end
end
