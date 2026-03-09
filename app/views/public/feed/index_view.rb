# frozen_string_literal: true

class Views::Public::Feed::IndexView < Views::Base
  def initialize(essays:)
    @essays = essays
  end

  def view_template
    content_for(:head) do
      view_context.meta_tags(
        title:       "Fieldnotes",
        description: "Writing on software, technology, and building things."
      )
    end

    h1(class: "text-3xl font-bold tracking-tight mb-8") { plain "Fieldnotes" }

    if @essays.empty?
      render Components::Shared::EmptyState.new("No posts yet.")
    else
      @essays.each { render Components::Essays::EssayCard.new(essay: it) }
    end
  end
end
