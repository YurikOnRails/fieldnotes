# frozen_string_literal: true

class Views::Layouts::ApplicationLayout < Views::Base
  include Phlex::Rails::Layout

  NAV_LINK = "relative text-muted font-medium text-[0.9375rem] px-3 py-2 rounded-lg " \
             "transition hover:text-ink hover:bg-code-bg"
  ACTIVE   = "text-ink after:absolute after:bottom-[3px] after:left-3 after:right-3 " \
             "after:h-0.5 after:bg-accent after:rounded-sm after:content-['']"
  FOOTER_LINK = "text-muted hover:text-accent transition"

  def view_template(&block)
    doctype
    html(lang: "en") do
      head do
        render_title
        meta name: "viewport", content: "width=device-width,initial-scale=1"
        meta name: "apple-mobile-web-app-capable", content: "yes"
        meta name: "application-name", content: "Fieldnotes"
        meta name: "mobile-web-app-capable", content: "yes"
        unsafe_raw csrf_meta_tags
        unsafe_raw csp_meta_tag
        unsafe_raw content_for(:head) || view_context.meta_tags(
          title: "Fieldnotes",
          description: "Writing on software, technology, and building things."
        )
        unsafe_raw view_context.tag.link(rel: "manifest", href: pwa_manifest_path(format: :json))
        link rel: "icon", href: "/icon.png", type: "image/png"
        link rel: "icon", href: "/icon.svg", type: "image/svg+xml"
        link rel: "apple-touch-icon", href: "/icon.png"
        stylesheet_link_tag "tailwind", "data-turbo-track": "reload"
        stylesheet_link_tag "lexxy-content", "lexxy-overrides", "data-turbo-track": "reload"
        javascript_importmap_tags
      end
      body(class: "bg-bg text-ink font-sans antialiased flex flex-col min-h-screen") do
        render_header
        main(class: cx("flex-1 max-w-content mx-auto px-6 py-12 w-full",
                        content_for(:main_class))) do
          render Components::Shared::FlashMessages.new(flash)
          yield
        end
        render_footer
      end
    end
  end

  private

  def render_title
    raw_title = content_for(:title)
    title { plain raw_title.present? ? "#{raw_title} — Fieldnotes" : "Fieldnotes" }
  end

  def render_header
    header(class: "border-b border-border bg-surface sticky top-0 z-10") do
      nav(class: "max-w-[90rem] mx-auto px-6 h-[3.25rem] flex items-center justify-between gap-6") do
        link_to "Fieldnotes", root_path,
                class: "font-bold text-base tracking-tight text-ink hover:text-accent flex-shrink-0"
        div(class: "flex items-center gap-1") do
          nav_link "Essays",  essays_path,      "essays"
          nav_link "Builds",  builds_path,      "builds"
          nav_link "Reading", books_path,        "books"
          nav_link "Field",   field_index_path, "field"
          nav_link "Now",     now_path,         "now"
        end
      end
    end
  end

  def render_footer
    footer(class: "border-t border-border") do
      nav(class: "max-w-[90rem] mx-auto px-6 py-8 flex gap-6 text-sm") do
        link_to "About",   about_path,                       class: FOOTER_LINK
        link_to "Uses",    uses_path,                        class: FOOTER_LINK
        link_to "Contact", contact_path,                     class: FOOTER_LINK
        link_to "GitHub",  "https://github.com/YurikOnRails", class: FOOTER_LINK
        link_to "RSS",     feed_path(format: :rss),          class: FOOTER_LINK
      end
    end
  end

  def nav_link(label, path, controller_name)
    active = controller_path.end_with?(controller_name)
    link_to label, path,
            class: cx(NAV_LINK, active ? ACTIVE : nil),
            aria: { current: active ? "page" : nil }
  end
end
