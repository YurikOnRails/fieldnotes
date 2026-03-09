# frozen_string_literal: true

class Views::Admin::Books::NewView < Views::Base
  include Views::Admin::Shared::AdminHelpers

  def initialize(book:)
    @book = book
  end

  def view_template
    content_for(:title, "New Book")
    admin_toolbar(title: "New Book")
    render Views::Admin::Books::FormView.new(book: @book)
  end
end
