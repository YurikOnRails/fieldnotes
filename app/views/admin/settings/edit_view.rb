# frozen_string_literal: true

class Views::Admin::Settings::EditView < Views::Base
  include Views::Admin::Shared::AdminHelpers

  def initialize(setting:)
    @setting = setting
  end

  def view_template
    content_for(:title, "Settings")
    admin_toolbar(title: "Settings")
    error_list(@setting)

    form_with model: @setting, url: admin_settings_path, method: :patch do |f|
      admin_card(title: "Watermark") do
        div(class: "mb-4") do
          div(class: "flex items-center gap-3") do
            unsafe_raw f.check_box(:watermark_enabled, class: "w-4 h-4 accent-accent")
            unsafe_raw f.label(:watermark_enabled, "Enable watermark on Field photos", class: "text-sm text-[#1C1917] cursor-pointer")
          end
        end
        div(class: "mb-4") do
          unsafe_raw f.label(:watermark, "Watermark image (PNG with transparency)", class: LABEL)
          unsafe_raw f.file_field(:watermark, accept: "image/png", class: "text-sm text-[#57534E] cursor-pointer")
          if @setting.watermark.attached?
            p(class: HINT) { plain "Current: #{@setting.watermark.filename} — upload a new file to replace it" }
            div(class: "mt-2 p-2 bg-[#888] rounded inline-block") do
              image_tag @setting.watermark, alt: "Watermark preview", class: "max-h-[60px]"
            end
          end
        end
        div(class: "mb-4") do
          unsafe_raw f.label(:watermark_position, "Position", class: LABEL)
          unsafe_raw f.select(:watermark_position, [
            ["Bottom right", "bottom_right"],
            ["Bottom left",  "bottom_left"],
            ["Top right",    "top_right"],
            ["Top left",     "top_left"]
          ], {}, class: INPUT)
        end
        div(class: "mb-0") do
          unsafe_raw f.label(:watermark_opacity, "Opacity (10–80%)", class: LABEL)
          unsafe_raw f.number_field(:watermark_opacity, min: 10, max: 80, step: 5, class: INPUT)
        end
      end

      unsafe_raw f.submit("Save settings", class: BTN_PRIMARY)
    end

    hr(class: "border-none border-t border-[#E8E3DC] my-8")

    admin_card(title: "Regenerate watermarks") do
      p(class: HINT) do
        plain "Apply current watermark settings to all Field photos. Runs in background."
      end
      button_to "Regenerate all watermarks",
                regenerate_watermarks_admin_settings_path,
                method: :post,
                class: "#{BTN_SECONDARY} mt-3",
                data: { turbo_confirm: "This will re-process all Field photos in the background. Continue?" }
    end
  end
end
