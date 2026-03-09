# frozen_string_literal: true

class Views::Layouts::AdminLayout < Views::Base
  include Phlex::Rails::Layout

  NAV_LINK    = "text-[#A8A29E] text-sm px-2.5 py-1.5 rounded-md transition " \
                "hover:text-white hover:bg-white/10 no-underline"
  ACTIVE_LINK = "text-white bg-white/10"

  def view_template(&block)
    doctype
    html(lang: "en") do
      head do
        raw_title = content_for(:title)
        title { plain raw_title.present? ? "#{raw_title} — Admin" : "Admin — Fieldnotes" }
        meta name: "viewport", content: "width=device-width,initial-scale=1"
        unsafe_raw csrf_meta_tags
        unsafe_raw csp_meta_tag
        stylesheet_link_tag "tailwind", "data-turbo-track": "reload"
        stylesheet_link_tag "lexxy-content", "lexxy-overrides", "data-turbo-track": "reload"
        javascript_importmap_tags
      end
      body(class: "bg-[#F5F4F2] font-sans text-[#1C1917] min-h-screen") do
        render_nav
        main(class: "max-w-[960px] mx-auto px-6 py-8 pb-16") do
          render Components::Shared::FlashMessages.new(flash)
          yield
        end
      end
    end
  end

  private

  def render_nav
    nav(class: "bg-[#1C1917] text-white px-6 h-12 flex items-center gap-1 sticky top-0 z-10") do
      span(class: "text-white font-semibold text-[0.9375rem] mr-4 pr-4 border-r border-[#3C3A38]") do
        plain "Fieldnotes"
      end
      admin_nav_link "Essays",   admin_essays_path,       "essays"
      admin_nav_link "Builds",   admin_builds_path,       "builds"
      admin_nav_link "Books",    admin_books_path,        "books"
      admin_nav_link "Field",    admin_field_index_path,  "field"
      span(class: "flex-1")
      admin_nav_link "Now",      edit_admin_now_path,      "nows"
      admin_nav_link "Profile",  edit_admin_profile_path, "profiles"
      admin_nav_link "Settings", edit_admin_settings_path, "settings"
      button_to "Sign out", session_path, method: :delete,
                class: "bg-transparent border border-[#3C3A38] text-[#A8A29E] " \
                       "px-3 py-1 rounded-md text-[0.8125rem] cursor-pointer " \
                       "hover:border-[#78716C] hover:text-white transition ml-2"
    end
  end

  def admin_nav_link(label, path, controller_name)
    cn = controller_name
    active = cn == controller_name || (controller_name == "field" && cn.in?(%w[field field_items]))
    link_to label, path, class: cx(NAV_LINK, active ? ACTIVE_LINK : nil),
            aria: { current: active ? "page" : nil }
  end
end
