# frozen_string_literal: true

class Components::Builds::BuildCard < Components::Base
  CARD  = "bg-surface border border-border rounded-lg p-6 flex flex-col gap-3 " \
          "transition hover:border-accent hover:-translate-y-0.5"
  TITLE = "text-[1.0625rem] font-semibold mb-0"
  LINK  = "text-ink hover:text-accent"
  DESC  = "text-muted text-[0.9375rem] leading-relaxed m-0"

  def initialize(build:)
    @build = build
  end

  def view_template
    article(class: CARD) do
      div(class: "text-3xl leading-none") { plain @build.icon_emoji }
      div(class: "flex-1") do
        h3(class: TITLE) do
          if @build.url.present?
            link_to @build.title, @build.url, class: LINK, target: "_blank", rel: "noopener noreferrer"
          else
            plain @build.title
          end
        end
        p(class: DESC) { plain @build.description } if @build.description.present?
      end
      render Components::Shared::Badge.new(@build.status)
    end
  end
end
