# frozen_string_literal: true

class Views::Admin::Field::EditView < Views::Base
  include Views::Admin::Shared::AdminHelpers

  def initialize(series:)
    @series = series
  end

  def view_template
    content_for(:title, "Edit #{@series.title}")
    admin_toolbar(title: "Edit Series")
    render Views::Admin::Field::FormView.new(series: @series)

    hr(class: "border-none border-t border-[#E8E3DC] my-8")
    div(class: "flex items-center gap-4") do
      p(class: "text-xs text-[#78716C] m-0") { plain "Danger Zone" }
      button_to "Delete Series", admin_field_path(@series), method: :delete,
                class: BTN_DANGER,
                form: { data: { turbo_confirm: "Delete «#{@series.title}»?" } }
    end
  end
end
