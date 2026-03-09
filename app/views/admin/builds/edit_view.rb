# frozen_string_literal: true

class Views::Admin::Builds::EditView < Views::Base
  include Views::Admin::Shared::AdminHelpers

  def initialize(build:)
    @build = build
  end

  def view_template
    content_for(:title, "Edit Build")
    admin_toolbar(title: "Edit Build")
    render Views::Admin::Builds::FormView.new(build: @build)

    hr(class: "border-none border-t border-[#E8E3DC] my-8")
    div(class: "flex items-center gap-4") do
      p(class: "text-xs text-[#78716C] m-0") { plain "Danger Zone" }
      button_to "Delete Build", admin_build_path(@build), method: :delete,
                class: BTN_DANGER,
                form: { data: { turbo_confirm: "Delete «#{@build.title}»?" } }
    end
  end
end
