class Admin::BooksController < Admin::BaseController
  before_action :set_book, only: [:edit, :update, :destroy]

  def index
    @books = Book.by_year
    render Views::Admin::Books::IndexView.new(books: @books)
  end

  def new
    @book = Book.new
    render Views::Admin::Books::NewView.new(book: @book)
  end

  def create
    @book = Book.new(book_params)
    if @book.save
      redirect_to edit_admin_book_url(@book), notice: "Book created"
    else
      render Views::Admin::Books::NewView.new(book: @book), status: :unprocessable_entity
    end
  end

  def edit
    render Views::Admin::Books::EditView.new(book: @book)
  end

  def update
    if @book.update(book_params)
      redirect_to edit_admin_book_url(@book), notice: "Book updated"
    else
      render Views::Admin::Books::EditView.new(book: @book), status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to admin_books_url, notice: "Book deleted"
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:isbn, :title, :author, :cover_url, :year_read,
                                 :rating, :key_idea, :review, :status)
  end
end
