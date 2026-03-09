class Public::BooksController < Public::BaseController
  rate_limit to: 60, within: 1.minute

  def index
    @reading = Book.reading.by_year
    @books   = Book.completed.by_year
    fresh_when etag: Book.maximum(:updated_at)
    render Views::Public::Books::IndexView.new(books: @books, reading: @reading)
  end

  def show
    @book = Book.find(params[:id])
    fresh_when @book
    render Views::Public::Books::ShowView.new(book: @book)
  end
end
