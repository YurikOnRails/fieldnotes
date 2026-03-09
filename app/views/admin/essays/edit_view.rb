# frozen_string_literal: true

class Views::Admin::Essays::EditView < Views::Base
  include Views::Admin::Shared::AdminHelpers

  def initialize(essay:)
    @essay = essay
  end

  def view_template
    content_for(:title, "Edit Essay")

    admin_toolbar(title: "Edit Essay") do
      if @essay.published?
        link_to "View on site", essay_path(@essay.slug), target: "_blank", class: BTN_SECONDARY
      end
    end

    render Views::Admin::Essays::FormView.new(essay: @essay)

    hr(class: "border-none border-t border-[#E8E3DC] my-8")
    div(class: "flex items-center gap-4") do
      p(class: "text-xs text-[#78716C] m-0") { plain "Danger Zone" }
      button_to "Delete Essay", admin_essay_path(@essay), method: :delete,
                class: BTN_DANGER,
                form: { data: { turbo_confirm: "Delete «#{@essay.title}»?" } }
    end
  end
end
