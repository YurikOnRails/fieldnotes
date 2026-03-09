# frozen_string_literal: true

class Components::Builds::ProfileHero < Components::Base
  def initialize(profile:)
    @profile = profile
  end

  def view_template
    section(class: "flex items-center gap-6 mb-12 pb-8 border-b border-border") do
      div(class: "flex-shrink-0") do
        if @profile.avatar.attached?
          image_tag @profile.avatar, alt: @profile.name,
                    class: "w-24 h-24 rounded-full object-cover"
        else
          img src: "/avatar.jpg", alt: @profile.name,
              class: "w-24 h-24 rounded-full object-cover"
        end
      end
      div do
        h2(class: "text-2xl font-bold mb-1") { plain @profile.name }
        if @profile.bio.present?
          div(class: "text-muted lexxy-content") { unsafe_raw @profile.bio.to_s }
        end
      end
    end
  end
end
