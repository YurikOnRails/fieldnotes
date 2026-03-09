# frozen_string_literal: true

class Views::Public::Field::ShowView < Views::Base
  def initialize(series:)
    @series = series
  end

  def view_template
    content_for(:title, @series.title)
    content_for(:main_class, "site-main--wide")
    content_for(:head) do
      view_context.meta_tags(
        title:       @series.title,
        description: @series.description.presence || @series.title
      )
    end

    div(class: "field-show") do
      nav(class: "field-breadcrumb mb-6") do
        link_to "← Field", field_index_path, class: "text-muted hover:text-accent transition"
      end

      header(class: "mb-8") do
        h1(class: "text-4xl font-bold mb-3") { plain @series.title }
        div(class: "flex items-center gap-3 flex-wrap mb-3") do
          if @series.location.present?
            span(class: "text-muted") { plain "📍 #{@series.location}" }
            span(class: "text-border") { plain "·" }
          end
          if @series.taken_on.present?
            time(class: "text-muted",
                 datetime: @series.taken_on.iso8601) do
              plain @series.taken_on.strftime("%B %Y")
            end
            span(class: "text-border") { plain "·" }
          end
          render Components::Shared::Badge.new(@series.kind)
        end
        p(class: "text-muted leading-relaxed") { plain @series.description } if @series.description.present?
      end

      div(class: "field-gallery space-y-8") do
        @series.field_items.ordered.each_with_index do |item, index|
          figure(class: "field-figure") do
            if item.photo.attached?
              div(class: "rounded-lg overflow-hidden") do
                unsafe_raw view_context.picture_tag(
                  view_context.field_item_photo(item),
                  alt:     item.caption.presence || @series.title,
                  sizes:   "(max-width: 768px) 100vw, (max-width: 1440px) 95vw, 1392px",
                  loading: index.zero? ? "eager" : "lazy"
                )
              end
            elsif item.youtube_url.present?
              video_id = item.youtube_url.match(/(?:v=|youtu\.be\/)([^&?\s]+)/)&.captures&.first
              if video_id
                div(class: "rounded-lg overflow-hidden aspect-video") do
                  iframe src: "https://www.youtube-nocookie.com/embed/#{video_id}",
                         title: item.caption.presence || @series.title,
                         class: "w-full h-full",
                         allow: "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture",
                         allowfullscreen: true,
                         loading: "lazy"
                end
              end
            end

            if item.caption.present?
              figcaption(class: "text-muted text-sm mt-2 text-center italic") do
                plain item.caption
              end
            end
          end
        end
      end
    end
  end
end
