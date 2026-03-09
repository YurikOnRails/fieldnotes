# frozen_string_literal: true

class Views::Public::Field::IndexView < Views::Base
  def initialize(series:)
    @series = series
  end

  def view_template
    content_for(:title, "Field")
    content_for(:head) do
      view_context.meta_tags(title: "Field", description: "Photo and video expedition series.")
    end

    h1(class: "text-3xl font-bold tracking-tight mb-8") { plain "Field" }

    if @series.empty?
      render Components::Shared::EmptyState.new("No field series yet.")
    else
      div(class: "grid grid-cols-1 sm:grid-cols-2 gap-6") do
        @series.each { render Components::Field::FieldCard.new(series: it) }
      end
    end
  end
end
