import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label", "value"]
  static values = { expiry: String }

  connect() {
    this.tick = this.tick.bind(this)
    this.tick()
    this.interval = window.setInterval(this.tick, 1000)
  }

  disconnect() {
    if (this.interval) window.clearInterval(this.interval)
  }

  tick() {
    const expiryTime = new Date(this.expiryValue).getTime()
    const remainingSeconds = Math.max(Math.floor((expiryTime - Date.now()) / 1000), 0)

    if (this.hasValueTarget) this.valueTarget.textContent = this.formatTime(remainingSeconds)

    if (remainingSeconds === 0) {
      if (this.hasLabelTarget) this.labelTarget.textContent = "available now"
      window.clearInterval(this.interval)
      window.location.reload()
    }
  }

  formatTime(totalSeconds) {
    const hours = Math.floor(totalSeconds / 3600)
    const minutes = Math.floor((totalSeconds % 3600) / 60)
    const seconds = totalSeconds % 60

    return [hours, minutes, seconds].map((unit) => String(unit).padStart(2, "0")).join(":")
  }
}
