# frozen_string_literal: true

class Components::Field::FieldCard < Components::Base
  CARD  = "bg-surface border border-border rounded-lg overflow-hidden " \
          "relative cursor-pointer transition hover:-translate-y-0.5 hover:shadow-md"
  TITLE = "text-lg font-bold mb-1"
  LINK  = "text-ink hover:text-accent after:absolute after:inset-0 after:content-['']"
  DESC  = "text-muted text-sm mb-3"
  FOOT  = "flex items-center gap-3 flex-wrap"

  def initialize(series:)
    @series = series
  end

  def view_template
    cover_item = @series.field_items.find { it.photo.attached? }

    article(class: CARD) do
      if cover_item
        div(class: "w-full aspect-video overflow-hidden") do
          unsafe_raw helpers.picture_tag(
            cover_item.photo,
            alt: @series.title,
            sizes: "(max-width: 768px) 100vw, 50vw"
          )
        end
      end

      div(class: "p-5") do
        h2(class: TITLE) do
          link_to @series.title, field_path(@series.slug), class: LINK
        end
        p(class: DESC) { plain @series.description } if @series.description.present?
        div(class: FOOT) do
          render Components::Shared::Badge.new(@series.kind)
          if @series.location.present?
            span(class: "text-muted text-sm") { plain "📍 #{@series.location}" }
          end
          if @series.taken_on.present?
            time(class: "text-muted text-sm",
                 datetime: @series.taken_on.iso8601) do
              plain @series.taken_on.strftime("%b %Y")
            end
          end
        end
      end
    end
  end
end
