class Public::BooksController < Public::BaseController
  rate_limit to: 60, within: 1.minute

  def index
    @books = Book.by_year
    fresh_when @books
  end

  def show
    @book = Book.find(params[:id])
    fresh_when @book
  end
end
