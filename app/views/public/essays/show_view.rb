# frozen_string_literal: true

class Views::Public::Essays::ShowView < Views::Base
  def initialize(essay:)
    @essay = essay
  end

  def view_template
    content_for(:title, @essay.title)
    content_for(:main_class, "max-w-[70ch]")
    content_for(:head) do
      view_context.meta_tags(
        title:        @essay.title,
        description:  @essay.excerpt.presence || @essay.title,
        image:        @essay.cover.attached? ? url_for(@essay.cover) : nil,
        type:         :article,
        published_at: @essay.published_at
      )
    end

    article do
      h1(class: "text-4xl font-bold tracking-tight mb-4") { plain @essay.title }
      div(class: "text-muted text-sm mb-10") do
        time(datetime: @essay.published_at.iso8601) do
          plain @essay.published_at.strftime("%B %d, %Y")
        end
      end
      div(class: "lexxy-content") do
        unsafe_raw @essay.content.to_s
      end
    end
  end
end
