# frozen_string_literal: true

class Views::Admin::Field::ShowView < Views::Base
  include Views::Admin::Shared::AdminHelpers

  def initialize(series:)
    @series = series
  end

  def view_template
    content_for(:title, @series.title)

    admin_toolbar(title: @series.title) do
      link_to "Edit series", edit_admin_field_path(@series), class: BTN_SECONDARY
      link_to "View on site", field_path(@series.slug), target: "_blank", class: BTN_SECONDARY
    end

    h2(class: "text-lg font-semibold mb-4 text-[#1C1917]") do
      plain "Items (#{@series.field_items.count})"
    end

    @series.field_items.ordered.each do |item|
      div(class: "bg-white rounded-xl shadow-sm p-4 mb-3 flex items-start justify-between gap-4") do
        div(class: "flex items-start gap-4 flex-1 min-w-0") do
          if item.photo.attached?
            div(class: "flex-shrink-0") do
              image_tag item.photo.variant(:thumb), alt: item.caption.to_s,
                        class: "w-[120px] h-[90px] object-cover rounded-md"
            end
          end
          div(class: "flex-1 min-w-0") do
            render Components::Shared::Badge.new(item.kind)
            p(class: "text-sm text-[#1C1917] mt-1.5") { plain item.caption } if item.caption.present?
            p(class: "text-xs text-[#78716C] mt-1") { plain item.youtube_url } if item.youtube_url.present?
            p(class: "text-xs text-[#78716C] mt-1") { plain "Position: #{item.position}" }
          end
        end
        div(class: "flex-shrink-0") do
          button_to "Delete", admin_field_field_item_path(@series, item), method: :delete,
                    class: BTN_DANGER,
                    form: { data: { turbo_confirm: "Delete this item?" } }
        end
      end
    end

    div(class: "bg-white rounded-xl shadow-sm p-6 mt-6") do
      h2(class: "text-lg font-semibold mb-4 text-[#1C1917]") { plain "Add item" }
      form_with model: [@series, FieldItem.new], url: admin_field_field_items_path(@series) do |f|
        field_row_simple f, :kind,        f.select(:kind, FieldItem::KINDS, {}, class: INPUT_ADMIN)
        field_row_simple f, :photo,       f.file_field(:photo, accept: "image/*",
                                                              class: "text-sm text-[#57534E] cursor-pointer")
        field_row_simple f, :caption,     f.text_field(:caption, class: INPUT_ADMIN)
        field_row_simple f, :youtube_url, f.url_field(:youtube_url, class: INPUT_ADMIN),
                         label: "YouTube URL (for videos)"
        field_row_simple f, :position,    f.number_field(:position,
                                                          value: (@series.field_items.maximum(:position).to_i + 1),
                                                          class: INPUT_ADMIN)
        unsafe_raw f.submit("Add item", class: BTN_PRIMARY)
      end
    end
  end

  private

  INPUT_ADMIN = "w-full px-3 py-2 border border-[#D6D3D1] rounded-md text-sm text-[#1C1917] " \
                "bg-white focus:outline-none focus:border-accent transition"

  def field_row_simple(f, name, input_html, label: nil)
    div(class: "mb-4") do
      unsafe_raw f.label(name, label || name.to_s.humanize, class: LABEL)
      unsafe_raw input_html
    end
  end
end
