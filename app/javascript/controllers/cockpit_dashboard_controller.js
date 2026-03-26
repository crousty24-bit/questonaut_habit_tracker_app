import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.reset()
  }

  parallax(event) {
    const rect = this.element.getBoundingClientRect()
    const x = ((event.clientX - rect.left) / rect.width - 0.5) * 2
    const y = ((event.clientY - rect.top) / rect.height - 0.5) * 2

    this.element.style.setProperty("--cockpit-pan-x", `${(x * 12).toFixed(2)}px`)
    this.element.style.setProperty("--cockpit-pan-y", `${(y * 10).toFixed(2)}px`)
  }

  reset() {
    this.element.style.setProperty("--cockpit-pan-x", "0px")
    this.element.style.setProperty("--cockpit-pan-y", "0px")
  }
}
