# frozen_string_literal: true

class Views::Public::Pages::AboutView < Views::Base
  def view_template
    content_for(:title, "About")
    content_for(:head) do
      view_context.meta_tags(title: "About", description: "About Fieldnotes and its author.")
    end

    h1(class: "text-3xl font-bold tracking-tight mb-8") { plain "About" }

    div(class: "prose-like space-y-4 text-ink leading-relaxed") do
      p { plain "I'm a software developer and writer based in [City]. I've been building software for over 10 years — mostly web applications, mostly with Ruby on Rails." }
      p { plain "This site is where I think out loud. I write about software architecture, the craft of building products, and lessons learned from shipping things. I try to write the post I wish I had found when I was stuck." }
      p { plain "Outside of code I read a lot, spend time outdoors, and occasionally take my camera somewhere interesting." }

      h2(class: "text-xl font-semibold mt-8 mb-3") { plain "Work" }
      p { plain "I'm currently working on [current project or role]. Previously I worked at [company] where I built [thing]." }
      p do
        plain "If you want to see what I'm working on right now, check the "
        link_to "Now", now_path, class: "text-accent hover:text-accent-hover"
        plain " page."
      end
    end
  end
end
