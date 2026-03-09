# frozen_string_literal: true

class Views::Admin::Builds::FormView < Views::Base
  include Views::Admin::Shared::AdminHelpers

  def initialize(build:)
    @build = build
  end

  def view_template
    error_list(@build)

    form_with model: [:admin, @build] do |f|
      admin_card do
        field f, :title,       f.text_field(:title, class: INPUT)
        field f, :description, f.text_area(:description, rows: 3, class: INPUT)
        field f, :url,         f.url_field(:url, class: INPUT)
        field f, :icon_emoji,  f.text_field(:icon_emoji, class: INPUT)
        field f, :status,      f.select(:status, Build::STATUSES, {}, class: INPUT)
        field f, :kind,        f.select(:kind, Build::KINDS, {}, class: INPUT)
        field f, :position,    f.number_field(:position, class: INPUT)
        field f, :started_on,  f.date_field(:started_on, class: INPUT)
        field f, :finished_on, f.date_field(:finished_on, class: INPUT)
      end

      unsafe_raw f.submit("Save", class: BTN_PRIMARY)
    end
  end

  private

  def field(f, name, input_html, hint: nil)
    div(class: "mb-4 last:mb-0") do
      unsafe_raw f.label(name, name.to_s.humanize, class: LABEL)
      unsafe_raw input_html
      p(class: HINT) { plain hint } if hint
    end
  end
end
