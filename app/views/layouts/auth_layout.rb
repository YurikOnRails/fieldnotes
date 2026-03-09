# frozen_string_literal: true

class Views::Layouts::AuthLayout < Views::Base
  include Phlex::Rails::Layout

  def view_template(&block)
    doctype
    html(lang: "en") do
      head do
        title { plain "Sign in — Fieldnotes" }
        meta name: "viewport", content: "width=device-width,initial-scale=1"
        unsafe_raw csrf_meta_tags
        unsafe_raw csp_meta_tag
        stylesheet_link_tag "tailwind", "data-turbo-track": "reload"
        javascript_importmap_tags
      end
      body(class: "bg-[#F5F4F2] flex items-center justify-center min-h-screen") do
        main(class: "w-full px-6") do
          div(class: "bg-white rounded-xl shadow-lg p-8 w-full max-w-sm mx-auto") do
            yield
          end
        end
      end
    end
  end
end
