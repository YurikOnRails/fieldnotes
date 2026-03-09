# frozen_string_literal: true

class Views::Admin::Books::IndexView < Views::Base
  include Views::Admin::Shared::AdminHelpers

  TABLE_TH = "text-left text-[0.6875rem] font-semibold uppercase tracking-[0.07em] " \
             "text-[#78716C] px-4 py-2.5 border-b border-[#E8E3DC] bg-[#FAFAF9]"
  TABLE_TD = "px-4 py-3 border-b border-[#F0EDE8] align-middle text-[#1C1917] text-sm"

  def initialize(books:)
    @books = books
  end

  def view_template
    content_for(:title, "Books")

    admin_toolbar(title: "Books") do
      link_to "New Book", new_admin_book_path, class: BTN_PRIMARY
    end

    if @books.any?
      div(class: "bg-white rounded-xl overflow-hidden shadow-sm") do
        table(class: "w-full border-collapse") do
          thead do
            tr do
              th(class: TABLE_TH) { plain "Title" }
              th(class: TABLE_TH) { plain "Author" }
              th(class: TABLE_TH) { plain "Status" }
              th(class: TABLE_TH) { plain "Rating" }
              th(class: TABLE_TH)
            end
          end
          tbody do
            @books.each do |book|
              tr(class: "hover:bg-[#FAFAF9] transition") do
                td(class: TABLE_TD) do
                  link_to book.title, edit_admin_book_path(book),
                          class: "text-accent hover:text-[#D4631E] font-medium"
                end
                td(class: "#{TABLE_TD} text-[#78716C]") { plain book.author }
                td(class: TABLE_TD) { render Components::Shared::Badge.new(book.status) }
                td(class: TABLE_TD) { plain book.rating ? "★" * book.rating : "—" }
                td(class: TABLE_TD)
              end
            end
          end
        end
      end
    else
      p(class: "text-center py-12 text-[#78716C] text-sm") do
        plain "No books yet. "
        link_to "Add your first one", new_admin_book_path, class: "text-accent"
      end
    end
  end
end
