# frozen_string_literal: true

class Views::Admin::Field::NewView < Views::Base
  include Views::Admin::Shared::AdminHelpers

  def initialize(series:)
    @series = series
  end

  def view_template
    content_for(:title, "New Field Series")
    admin_toolbar(title: "New Series")
    render Views::Admin::Field::FormView.new(series: @series)
  end
end
