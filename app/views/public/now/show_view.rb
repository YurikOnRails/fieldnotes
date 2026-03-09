# frozen_string_literal: true

class Views::Public::Now::ShowView < Views::Base
  def initialize(current:, previous:)
    @current  = current
    @previous = previous
  end

  def view_template
    content_for(:title, "Now")
    content_for(:head) do
      view_context.meta_tags(title: "Now", description: "What I'm working on right now.")
    end

    h1(class: "text-3xl font-bold tracking-tight mb-8") { plain "Now" }

    if @current
      div(class: "lexxy-content mb-4") { unsafe_raw @current.body.to_s }
      p(class: "text-muted text-sm") do
        time(datetime: @current.published_at.iso8601) do
          plain "Updated #{@current.published_at.strftime("%B %d, %Y")}"
        end
      end
    end

    if @previous.any?
      section(class: "previous-entries mt-12") do
        h2(class: "text-xl font-semibold mb-4") { plain "Previous entries" }
        @previous.each do |entry|
          details(class: "border-t border-border py-4") do
            summary(class: "text-muted cursor-pointer hover:text-ink transition") do
              plain entry.published_at.strftime("%B %d, %Y")
            end
            div(class: "lexxy-content mt-3") { unsafe_raw entry.body.to_s }
          end
        end
      end
    end
  end
end
