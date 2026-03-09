# frozen_string_literal: true

class Views::Admin::Essays::NewView < Views::Base
  include Views::Admin::Shared::AdminHelpers

  def initialize(essay:)
    @essay = essay
  end

  def view_template
    content_for(:title, "New Essay")
    admin_toolbar(title: "New Essay")
    render Views::Admin::Essays::FormView.new(essay: @essay)
  end
end
