# frozen_string_literal: true

class Views::Public::Essays::IndexView < Views::Base
  def initialize(essays:)
    @essays = essays
  end

  def view_template
    content_for(:title, "Essays")
    content_for(:head) do
      view_context.meta_tags(title: "Essays", description: "Writing on software, technology, and building things.")
    end

    h1(class: "text-3xl font-bold tracking-tight mb-8") { plain "Essays" }

    if @essays.empty?
      render Components::Shared::EmptyState.new("No essays yet.")
    else
      @essays.each { render Components::Essays::EssayCard.new(essay: it) }
    end
  end
end
