# frozen_string_literal: true

class Views::Admin::Nows::EditView < Views::Base
  include Views::Admin::Shared::AdminHelpers

  def initialize(now_entry:, previous_entries:)
    @now_entry        = now_entry
    @previous_entries = previous_entries
  end

  def view_template
    content_for(:title, "Now")

    admin_toolbar(title: "Now") do
      link_to "View on site", now_path, target: "_blank", class: BTN_SECONDARY
    end

    admin_card do
      form_with model: @now_entry, url: admin_now_path, method: :patch do |f|
        div(class: "mb-4") do
          unsafe_raw f.rich_text_area(:body)
          p(class: HINT) { plain "Each update creates a new entry. Previous versions are kept as history." }
        end
        unsafe_raw f.submit("Update", class: BTN_PRIMARY)
      end
    end

    if @previous_entries.any?
      h2(class: "text-lg font-semibold mb-3 text-[#1C1917]") { plain "Previous entries" }
      @previous_entries.each do |entry|
        div(class: "bg-white rounded-xl shadow-sm px-4 py-3 mb-2") do
          p(class: "text-xs text-[#78716C]") do
            plain entry.published_at.strftime("%b %d, %Y at %H:%M")
          end
        end
      end
    end
  end
end
