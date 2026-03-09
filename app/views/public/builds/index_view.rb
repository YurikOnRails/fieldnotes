# frozen_string_literal: true

class Views::Public::Builds::IndexView < Views::Base
  def initialize(builds:, profile:)
    @builds   = builds
    @profile  = profile
  end

  def view_template
    content_for(:title, "Builds")
    content_for(:head) do
      view_context.meta_tags(title: "Builds", description: "Projects, businesses, and things I've built.")
    end

    render Components::Builds::ProfileHero.new(profile: @profile)

    h1(class: "text-3xl font-bold tracking-tight mb-8") { plain "Builds" }

    if @builds.empty?
      render Components::Shared::EmptyState.new("No builds yet.")
    else
      div(class: "grid grid-cols-1 sm:grid-cols-2 gap-6") do
        @builds.each { render Components::Builds::BuildCard.new(build: it) }
      end
    end
  end
end
