# frozen_string_literal: true

class Views::Public::Books::IndexView < Views::Base
  GRID = "grid gap-6 " \
         "grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5"

  def initialize(books:, reading:)
    @books   = books
    @reading = reading
  end

  def view_template
    content_for(:title, "Reading")
    content_for(:main_class, "max-w-[90rem]")
    content_for(:head) do
      view_context.meta_tags(title: "Reading", description: "Books I've read and key ideas from each.")
    end

    h1(class: "text-3xl font-bold tracking-tight mb-8") { plain "Reading" }

    if @reading.any?
      p(class: "text-muted text-sm mb-4") { plain "Currently reading" }
      div(class: "#{GRID} mb-12") do
        @reading.each { render Components::Books::BookCard.new(book: it) }
      end
    end

    if @books.empty? && @reading.empty?
      render Components::Shared::EmptyState.new("No books yet.")
    else
      div(class: GRID) do
        @books.each { render Components::Books::BookCard.new(book: it) }
      end
    end
  end
end
