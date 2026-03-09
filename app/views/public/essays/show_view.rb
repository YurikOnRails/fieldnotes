# frozen_string_literal: true

class Views::Public::Essays::ShowView < Views::Base
  def initialize(essay:)
    @essay = essay
  end

  def view_template
    content_for(:title, @essay.title)
    content_for(:main_class, "site-main--essay")
    content_for(:head) do
      view_context.meta_tags(
        title:        @essay.title,
        description:  @essay.excerpt.presence || @essay.title,
        image:        @essay.cover.attached? ? url_for(@essay.cover) : nil,
        type:         :article,
        published_at: @essay.published_at
      )
    end

    div(class: "essay-layout", data: { controller: "toc" }) do
      article(class: "essay-article", data: { toc_target: "content" }) do
        h1 { plain @essay.title }
        div(class: "essay-meta") do
          time(datetime: @essay.published_at.iso8601) do
            plain @essay.published_at.strftime("%B %d, %Y")
          end
        end
        div(class: "essay-content lexxy-content") do
          unsafe_raw @essay.content.to_s
        end
      end

      aside(class: "essay-toc", data: { toc_target: "nav" },
            aria: { label: "Table of contents" }) do
        p(class: "essay-toc__title") { plain "Contents" }
      end
    end
  end
end
