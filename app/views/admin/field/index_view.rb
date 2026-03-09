# frozen_string_literal: true

class Views::Admin::Field::IndexView < Views::Base
  include Views::Admin::Shared::AdminHelpers

  TABLE_TH = "text-left text-[0.6875rem] font-semibold uppercase tracking-[0.07em] " \
             "text-[#78716C] px-4 py-2.5 border-b border-[#E8E3DC] bg-[#FAFAF9]"
  TABLE_TD = "px-4 py-3 border-b border-[#F0EDE8] align-middle text-[#1C1917] text-sm"

  def initialize(series:)
    @series = series
  end

  def view_template
    content_for(:title, "Field Series")

    admin_toolbar(title: "Field Series") do
      link_to "New Series", new_admin_field_path, class: BTN_PRIMARY
    end

    if @series.any?
      div(class: "bg-white rounded-xl overflow-hidden shadow-sm") do
        table(class: "w-full border-collapse") do
          thead do
            tr do
              th(class: TABLE_TH) { plain "Title" }
              th(class: TABLE_TH) { plain "Kind" }
              th(class: TABLE_TH) { plain "Location" }
              th(class: TABLE_TH) { plain "Date" }
              th(class: TABLE_TH)
            end
          end
          tbody do
            @series.each do |s|
              tr(class: "hover:bg-[#FAFAF9] transition") do
                td(class: TABLE_TD) do
                  link_to s.title, admin_field_path(s),
                          class: "text-accent hover:text-[#D4631E] font-medium"
                end
                td(class: "#{TABLE_TD} text-[#78716C]") { plain s.kind }
                td(class: "#{TABLE_TD} text-[#78716C]") { plain s.location.to_s }
                td(class: "#{TABLE_TD} text-[#78716C]") { plain s.taken_on&.strftime("%b %d, %Y").to_s }
                td(class: "#{TABLE_TD} text-right") do
                  link_to "Edit", edit_admin_field_path(s),
                          class: "text-sm text-[#57534E] hover:text-[#1C1917] px-2 py-1 rounded hover:bg-[#F0EDE8] transition"
                end
              end
            end
          end
        end
      end
    else
      p(class: "text-center py-12 text-[#78716C] text-sm") do
        plain "No field series yet. "
        link_to "Create your first one", new_admin_field_path, class: "text-accent"
      end
    end
  end
end
