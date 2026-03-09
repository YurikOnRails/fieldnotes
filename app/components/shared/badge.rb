# frozen_string_literal: true

class Components::Shared::Badge < Components::Base
  VARIANTS = {
    reading:   "bg-purple-bg text-purple-text",
    completed: "bg-green-bg text-green-text",
    abandoned: "bg-surface text-muted",
    published: "bg-green-bg text-green-text",
    draft:     "bg-amber-bg text-amber-text",
    active:    "bg-green-bg text-green-text",
    paused:    "bg-amber-bg text-amber-text",
    archived:  "bg-surface text-muted",
    photo:     "bg-blue-bg text-blue-text",
    video:     "bg-purple-bg text-purple-text",
    mixed:     "bg-amber-bg text-amber-text",
  }.freeze

  BASE = "inline-block px-2.5 py-0.5 rounded-full text-[0.6875rem] font-bold tracking-wider uppercase"

  def initialize(status)
    @status = status.to_sym
  end

  def view_template
    span(class: cx(BASE, VARIANTS.fetch(@status, "bg-surface text-muted"))) do
      plain @status.to_s.capitalize
    end
  end
end
