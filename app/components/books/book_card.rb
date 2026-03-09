# frozen_string_literal: true

class Components::Books::BookCard < Components::Base
  def initialize(book:)
    @book = book
  end

  def view_template
    link_to book_path(@book), class: "flex flex-col gap-3 no-underline text-inherit group" do
      div(class: "w-full aspect-[2/3] rounded-lg overflow-hidden bg-surface shadow-sm " \
                 "transition group-hover:-translate-y-1 group-hover:shadow-md") do
        if @book.cover_image_url.present?
          img src: @book.cover_image_url, alt: @book.title,
              class: "w-full h-full object-cover block", loading: "lazy"
        else
          render Components::Books::BookPlaceholder.new(title: @book.title)
        end
      end
      div(class: "flex flex-col gap-0.5") do
        p(class: "text-[0.8125rem] font-semibold text-ink leading-snug") { plain @book.title }
        p(class: "text-xs text-muted") { plain @book.author }
        if @book.rating
          p(class: "text-[0.6875rem] text-accent tracking-widest") { plain "★" * @book.rating }
        end
      end
    end
  end
end
