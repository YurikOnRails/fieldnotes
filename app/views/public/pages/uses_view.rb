# frozen_string_literal: true

class Views::Public::Pages::UsesView < Views::Base
  def view_template
    content_for(:title, "Uses")
    content_for(:head) do
      view_context.meta_tags(title: "Uses", description: "Tools, gear, and software I use every day.")
    end

    h1(class: "text-3xl font-bold tracking-tight mb-8") { plain "Uses" }

    div(class: "space-y-6 text-ink leading-relaxed") do
      p do
        plain "A running list of tools and gear I use daily. Inspired by "
        a(href: "https://uses.tech", class: "text-accent hover:text-accent-hover") { plain "uses.tech" }
        plain "."
      end

      uses_section("Hardware") do
        uses_item("MacBook Pro 14\" M3", "main machine. Fast enough that I stopped thinking about performance.")
        uses_item("LG 27\" 4K monitor", "one external display, centered. I stopped using two monitors and never looked back.")
        uses_item("Sony WH-1000XM5", "noise cancelling headphones for deep work.")
      end

      uses_section("Editor & Terminal") do
        uses_item("Neovim", "primary editor. Took a month to set up properly, saves an hour a day.")
        uses_item("Ghostty", "terminal. Fast, native, no configuration needed to look good.")
        uses_item("tmux", "session management. One session per project.")
      end

      uses_section("Software") do
        uses_item("Arc", "browser. Spaces keep client work and personal browsing separate.")
        uses_item("Linear", "issue tracking for solo projects. Overkill but I like the keyboard shortcuts.")
        uses_item("Obsidian", "notes and writing drafts before they become essays here.")
        uses_item("Postico", "database GUI for when SQL in the terminal isn't enough.")
      end

      uses_section("Stack") do
        p { plain "Ruby on Rails, SQLite in production, deployed on a single Hetzner VPS via Kamal. This site is built the same way." }
      end
    end
  end

  private

  def uses_section(title, &block)
    div do
      h2(class: "text-xl font-semibold mt-8 mb-3") { plain title }
      yield
    end
  end

  def uses_item(name, description)
    p do
      strong(class: "text-ink font-semibold") { plain name }
      plain " — #{description}"
    end
  end
end
