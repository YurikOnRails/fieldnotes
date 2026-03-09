# frozen_string_literal: true

class Views::Admin::Profiles::EditView < Views::Base
  include Views::Admin::Shared::AdminHelpers

  def initialize(profile:)
    @profile = profile
  end

  def view_template
    content_for(:title, "Profile")
    admin_toolbar(title: "Profile")
    error_list(@profile)

    form_with model: @profile, url: admin_profile_path, method: :patch do |f|
      admin_card do
        field f, :name, f.text_field(:name, class: INPUT)
        div(class: "mb-4") do
          unsafe_raw f.label(:bio, "Bio", class: LABEL)
          unsafe_raw f.rich_text_area(:bio)
        end
        div(class: "mb-0") do
          unsafe_raw f.label(:avatar, "Avatar", class: LABEL)
          unsafe_raw f.file_field(:avatar, accept: "image/*", class: "text-sm text-[#57534E] cursor-pointer")
          if @profile.avatar.attached?
            p(class: HINT) { plain "Current: #{@profile.avatar.filename} — upload a new file to replace" }
            image_tag @profile.avatar, alt: "Avatar",
                      class: "w-20 h-20 rounded-full object-cover mt-2"
          end
        end
      end

      unsafe_raw f.submit("Save", class: BTN_PRIMARY)
    end
  end

  private

  def field(f, name, input_html)
    div(class: "mb-4 last:mb-0") do
      unsafe_raw f.label(name, name.to_s.humanize, class: LABEL)
      unsafe_raw input_html
    end
  end
end
