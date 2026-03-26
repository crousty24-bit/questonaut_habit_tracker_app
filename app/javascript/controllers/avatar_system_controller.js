import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["currentAvatar", "currentName", "radio", "form"]

  connect() {
    const selected = this.radioTargets.find((radio) => radio.checked) || this.radioTargets[0]
    if (selected) this.applySelection(selected)
  }

  update(event) {
    this.applySelection(event.currentTarget)
  }

  submit(event) {
    event.preventDefault()

    const selected = this.radioTargets.find((radio) => radio.checked)
    if (!selected) return

    console.log(selected.value)
  }

  applySelection(radio) {
    if (this.hasCurrentAvatarTarget) {
      this.currentAvatarTarget.src = radio.dataset.avatarSrc
      this.currentAvatarTarget.alt = radio.dataset.avatarName
    }

    if (this.hasCurrentNameTarget) {
      this.currentNameTarget.textContent = radio.dataset.avatarName
    }
  }
}
