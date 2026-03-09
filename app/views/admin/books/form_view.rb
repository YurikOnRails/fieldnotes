# frozen_string_literal: true

class Views::Admin::Books::FormView < Views::Base
  include Views::Admin::Shared::AdminHelpers

  def initialize(book:)
    @book = book
  end

  def view_template
    error_list(@book)

    form_with model: [:admin, @book] do |f|
      admin_card(title: "Book") do
        div(class: "mb-4") do
          unsafe_raw f.label(:isbn, "ISBN", class: LABEL)
          unsafe_raw f.text_field(:isbn, placeholder: "e.g. 9780134757599", class: INPUT)
          p(class: HINT) { plain "Enter ISBN — title, author, and cover will be fetched automatically." }
        end
        field f, :title,  f.text_field(:title, class: INPUT)
        field f, :author, f.text_field(:author, class: INPUT)
        if @book.cover_image_url.present?
          div(class: "mb-4") do
            p(class: LABEL) { plain "Cover preview" }
            img src: @book.cover_image_url, alt: "Cover",
                class: "max-h-40 rounded mt-1"
          end
        end
      end

      admin_card(title: "Your notes") do
        field f, :status,    f.select(:status, Book::STATUSES, {}, class: INPUT)
        field f, :rating,    f.number_field(:rating, min: 1, max: 5, class: INPUT)
        field f, :year_read, f.number_field(:year_read, class: INPUT)
        div(class: "mb-4") do
          unsafe_raw f.label(:key_idea, "Key idea (one sentence)", class: LABEL)
          unsafe_raw f.text_field(:key_idea,
                                   placeholder: "The one thing you took away from this book",
                                   class: INPUT)
        end
        div(class: "mb-0") do
          unsafe_raw f.label(:review, "Notes & review", class: LABEL)
          unsafe_raw f.rich_text_area(:review)
          p(class: HINT) { plain "Quotes, thoughts, detailed notes. Supports formatting." }
        end
      end

      unsafe_raw f.submit("Save", class: BTN_PRIMARY)
    end
  end

  private

  def field(f, name, input_html)
    div(class: "mb-4 last:mb-0") do
      unsafe_raw f.label(name, name.to_s.humanize, class: LABEL)
      unsafe_raw input_html
    end
  end
end
