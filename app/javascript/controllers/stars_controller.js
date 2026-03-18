import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (this.element.dataset.enhanced === "true") return

    this.element.dataset.enhanced = "true"

    for (let index = 0; index < 80; index += 1) {
      const star = document.createElement("div")
      star.className = "star"
      star.style.left = `${Math.random() * 100}%`
      star.style.top = `${Math.random() * 100}%`
      star.style.animationDelay = `${Math.random() * 3}s`
      this.element.appendChild(star)
    }
  }
}
