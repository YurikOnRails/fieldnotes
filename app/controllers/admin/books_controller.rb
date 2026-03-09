class Admin::BooksController < Admin::BaseController
  before_action :set_book, only: [:edit, :update, :destroy]

  def index
    @books = Book.by_year
  end

  def new
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)
    if @book.save
      redirect_to edit_admin_book_url(@book), notice: "Book created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to edit_admin_book_url(@book), notice: "Book updated"
    else
      render :edit, status: :unprocessable_entity
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
    params.require(:book).permit(:title, :author, :cover_url, :year_read,
                                 :rating, :key_idea, :status)
  end
end
