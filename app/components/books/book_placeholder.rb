# frozen_string_literal: true

class Components::Books::BookPlaceholder < Components::Base
  def initialize(title:)
    @title = title
  end

  def view_template
    div(class: "w-full h-full flex flex-col items-center justify-center gap-2 p-4 text-center",
        style: "background: linear-gradient(160deg, #2A1A0F 0%, #1A0F08 100%); border: 1px solid #3D2010;") do
      span(class: "text-2xl leading-none") { plain "📖" }
      span(class: "text-muted text-xs font-medium leading-snug") { plain @title }
    end
  end
end
