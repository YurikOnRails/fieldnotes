import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "nav"]

  connect() {
    const headings = this.contentTarget.querySelectorAll("h2, h3")
    if (headings.length < 2) {
      this.navTarget.hidden = true
      return
    }

    const items = Array.from(headings).map((h, i) => {
      if (!h.id) h.id = `section-${i}`
      const li = document.createElement("li")
      li.className = h.tagName === "H3" ? "toc-sub" : ""
      const a = document.createElement("a")
      a.href = `#${h.id}`
      a.textContent = h.textContent
      li.appendChild(a)
      return { el: li, link: a, heading: h }
    })

    const ul = document.createElement("ul")
    items.forEach(it => ul.appendChild(it.el))
    this.navTarget.appendChild(ul)

    const observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (!entry.isIntersecting) return
        items.forEach(it => it.link.classList.toggle("active", it.heading === entry.target))
      })
    }, { rootMargin: "0px 0px -65% 0px" })

    items.forEach(it => observer.observe(it.heading))
    this._observer = observer
  }

  disconnect() {
    this._observer?.disconnect()
  }
}
