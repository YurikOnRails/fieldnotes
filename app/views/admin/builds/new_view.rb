# frozen_string_literal: true

class Views::Admin::Builds::NewView < Views::Base
  include Views::Admin::Shared::AdminHelpers

  def initialize(build:)
    @build = build
  end

  def view_template
    content_for(:title, "New Build")
    admin_toolbar(title: "New Build")
    render Views::Admin::Builds::FormView.new(build: @build)
  end
end
