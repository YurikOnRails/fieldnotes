# frozen_string_literal: true

class Components::Essays::EssayCard < Components::Base
  CARD    = "bg-surface border border-border rounded-lg p-6 mb-6 shadow-sm " \
            "relative cursor-pointer transition hover:-translate-y-0.5 hover:shadow-md"
  TITLE   = "text-xl font-bold mb-2"
  LINK    = "text-ink hover:text-accent after:absolute after:inset-0 after:content-['']"
  EXCERPT = "text-muted mb-3"
  META    = "flex items-center gap-3 flex-wrap"

  def initialize(essay:)
    @essay = essay
  end

  def view_template
    article(class: CARD) do
      h2(class: TITLE) do
        link_to @essay.title, essay_path(@essay.slug), class: LINK
      end
      p(class: EXCERPT) { plain @essay.excerpt } if @essay.excerpt.present?
      div(class: META) do
        time(class: "text-muted text-sm",
             datetime: @essay.published_at.iso8601) do
          plain @essay.published_at.strftime("%B %-d, %Y")
        end
        render Components::Shared::Badge.new(@essay.status) unless @essay.published?
      end
    end
  end
end
