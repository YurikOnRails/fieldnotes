# frozen_string_literal: true

class Views::Public::Pages::ContactView < Views::Base
  def view_template
    content_for(:title, "Contact")
    content_for(:head) do
      view_context.meta_tags(title: "Contact", description: "Get in touch.")
    end

    h1(class: "text-3xl font-bold tracking-tight mb-8") { plain "Contact" }

    div(class: "space-y-4 text-ink leading-relaxed") do
      p do
        plain "Email is the best way to reach me: "
        a(href: "mailto:hello@example.com", class: "text-accent hover:text-accent-hover") do
          plain "hello@example.com"
        end
      end
      p { plain "I read every message and reply to most of them, usually within a few days. I'm happy to talk about software, writing, or anything you found on this site." }
      p do
        plain "You can also find me on "
        a(href: "https://github.com/username", class: "text-accent hover:text-accent-hover") { plain "GitHub" }
        plain " and "
        a(href: "https://twitter.com/username", class: "text-accent hover:text-accent-hover") { plain "Twitter" }
        plain "."
      end
    end
  end
end
