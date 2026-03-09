# frozen_string_literal: true

class Views::Admin::Field::FormView < Views::Base
  include Views::Admin::Shared::AdminHelpers

  def initialize(series:)
    @series = series
  end

  def view_template
    error_list(@series)

    url = @series.new_record? ? admin_field_index_path : admin_field_path(@series)
    form_with model: [:admin, @series], url: url do |f|
      admin_card do
        field f, :title,       f.text_field(:title, class: INPUT)
        field f, :description, f.text_area(:description, rows: 3, class: INPUT)
        field f, :kind,        f.select(:kind, FieldSeries::KINDS, {}, class: INPUT)
        field f, :location,    f.text_field(:location, class: INPUT)
        field f, :taken_on,    f.date_field(:taken_on, class: INPUT)
      end

      unsafe_raw f.submit("Save", class: BTN_PRIMARY)
    end
  end

  private

  def field(f, name, input_html)
    div(class: "mb-4 last:mb-0") do
      unsafe_raw f.label(name, name.to_s.humanize, class: LABEL)
      unsafe_raw input_html
    end
  end
end
