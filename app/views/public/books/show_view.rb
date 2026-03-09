# frozen_string_literal: true

class Views::Public::Books::ShowView < Views::Base
  def initialize(book:)
    @book = book
  end

  def view_template
    content_for(:title, @book.title)
    content_for(:head) do
      view_context.meta_tags(
        title:       "#{@book.title} — #{@book.author}",
        description: @book.key_idea.to_s.truncate(160),
        image:       @book.cover_image_url
      )
    end

    div(class: "flex gap-10 items-start flex-col sm:flex-row") do
      div(class: "flex-shrink-0 w-40") do
        if @book.cover_image_url.present?
          img src: @book.cover_image_url, alt: @book.title,
              class: "w-full rounded-lg shadow-md"
        else
          render Components::Books::BookPlaceholder.new(title: @book.title)
        end
      end

      div(class: "flex-1 min-w-0") do
        header(class: "mb-6") do
          h1(class: "text-3xl font-bold mb-1") { plain @book.title }
          p(class: "text-muted text-lg mb-3") { plain @book.author }
          div(class: "flex items-center gap-3 flex-wrap") do
            if @book.rating
              span(class: "text-accent tracking-widest") { plain "★" * @book.rating }
            end
            render Components::Shared::Badge.new(@book.status)
            if @book.year_read
              span(class: "text-muted text-sm") { plain "Read in #{@book.year_read}" }
            end
          end
        end

        if @book.key_idea.present?
          section(class: "mb-6") do
            h2(class: "text-xl font-semibold mb-2") { plain "Key idea" }
            p(class: "text-muted leading-relaxed") { plain @book.key_idea }
          end
        end

        if @book.review.present?
          section(class: "mb-6") do
            h2(class: "text-xl font-semibold mb-2") { plain "Notes & review" }
            div(class: "lexxy-content") { unsafe_raw @book.review.to_s }
          end
        end

        p { link_to "← Back to reading list", books_path, class: "text-muted hover:text-accent transition" }
      end
    end
  end
end
