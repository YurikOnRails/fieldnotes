# frozen_string_literal: true

class Views::Admin::Essays::IndexView < Views::Base
  include Views::Admin::Shared::AdminHelpers

  TABLE_TH = "text-left text-[0.6875rem] font-semibold uppercase tracking-[0.07em] " \
             "text-[#78716C] px-4 py-2.5 border-b border-[#E8E3DC] bg-[#FAFAF9]"
  TABLE_TD = "px-4 py-3 border-b border-[#F0EDE8] align-middle text-[#1C1917] text-sm"

  def initialize(essays:)
    @essays = essays
  end

  def view_template
    content_for(:title, "Essays")

    admin_toolbar(title: "Essays") do
      link_to "New Essay", new_admin_essay_path, class: BTN_PRIMARY
    end

    if @essays.any?
      div(class: "bg-white rounded-xl overflow-hidden shadow-sm") do
        table(class: "w-full border-collapse") do
          thead do
            tr do
              th(class: "#{TABLE_TH} w-[52px]")
              th(class: TABLE_TH) { plain "Title" }
              th(class: TABLE_TH) { plain "Status" }
              th(class: TABLE_TH) { plain "Published" }
              th(class: TABLE_TH)
            end
          end
          tbody do
            @essays.each do |essay|
              tr(class: "hover:bg-[#FAFAF9] transition") do
                td(class: TABLE_TD) do
                  if essay.cover.attached?
                    image_tag essay.cover,
                              class: "w-10 h-10 object-cover rounded block"
                  end
                end
                td(class: TABLE_TD) do
                  link_to essay.title, edit_admin_essay_path(essay),
                          class: "text-accent hover:text-[#D4631E] font-medium"
                end
                td(class: TABLE_TD) { render Components::Shared::Badge.new(essay.status) }
                td(class: TABLE_TD) do
                  plain essay.published_at&.strftime("%b %d, %Y").to_s
                end
                td(class: "#{TABLE_TD} text-right") do
                  if essay.published?
                    link_to "View", essay_path(essay.slug), target: "_blank",
                            class: "text-sm text-[#57534E] hover:text-[#1C1917] px-2 py-1 rounded hover:bg-[#F0EDE8] transition"
                  end
                end
              end
            end
          end
        end
      end
    else
      p(class: "text-center py-12 text-[#78716C] text-sm") do
        plain "No essays yet. "
        link_to "Write your first one", new_admin_essay_path, class: "text-accent"
      end
    end
  end
end
