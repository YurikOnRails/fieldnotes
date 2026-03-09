# frozen_string_literal: true

class Views::Admin::Essays::FormView < Views::Base
  include Views::Admin::Shared::AdminHelpers

  def initialize(essay:)
    @essay = essay
  end

  def view_template
    error_list(@essay)

    form_with model: [:admin, @essay] do |f|
      admin_card do
        field f, :title, f.text_field(:title, class: INPUT)
        field f, :excerpt, f.text_area(:excerpt, rows: 3, class: INPUT)
        field f, :status, f.select(:status, Essay::STATUSES, {}, class: INPUT)
        field f, :published_at,
              f.datetime_local_field(:published_at, class: INPUT),
              hint: "Leave blank — will be set automatically when published."
        field f, :cover, f.file_field(:cover, class: "text-sm text-[#57534E] cursor-pointer")
      end

      admin_card(title: "Content") do
        unsafe_raw f.rich_text_area(:content)
      end

      div(class: "flex items-center gap-3") do
        if @essay.published?
          unsafe_raw f.submit("Save", class: BTN_PRIMARY)
        else
          unsafe_raw f.submit("Save Draft", class: BTN_SECONDARY)
          unsafe_raw f.submit("Publish", class: BTN_PRIMARY)
        end
      end
    end
  end

  private

  def field(f, name, input_html, hint: nil, label: nil)
    div(class: "mb-4 last:mb-0") do
      unsafe_raw f.label(name, label || name.to_s.humanize, class: LABEL)
      unsafe_raw input_html
      p(class: HINT) { plain hint } if hint
    end
  end
end
