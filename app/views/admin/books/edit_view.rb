# frozen_string_literal: true

class Views::Admin::Books::EditView < Views::Base
  include Views::Admin::Shared::AdminHelpers

  def initialize(book:)
    @book = book
  end

  def view_template
    content_for(:title, "Edit Book")
    admin_toolbar(title: "Edit Book")
    render Views::Admin::Books::FormView.new(book: @book)

    hr(class: "border-none border-t border-[#E8E3DC] my-8")
    div(class: "flex items-center gap-4") do
      p(class: "text-xs text-[#78716C] m-0") { plain "Danger Zone" }
      button_to "Delete Book", admin_book_path(@book), method: :delete,
                class: BTN_DANGER,
                form: { data: { turbo_confirm: "Delete «#{@book.title}»?" } }
    end
  end
end
