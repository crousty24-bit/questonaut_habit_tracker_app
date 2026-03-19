import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field", "toast"]
  static values = {
    clearFields: Array,
    errorFields: Array,
    notificationMessage: String
  }

  connect() {
    this.applyFieldStates()
    this.showNotification()
  }

  disconnect() {
    this.clearTimers()
  }

  applyFieldStates() {
    this.fieldTargets.forEach((field) => {
      const fieldName = field.dataset.validationFeedbackField
      const hasError = this.errorFieldsValue.includes(fieldName)
      const shouldClear = this.clearFieldsValue.includes(fieldName)

      field.classList.toggle("error", hasError)

      if (shouldClear) {
        field.value = ""
      }
    })
  }

  showNotification() {
    if (!this.hasToastTarget || !this.notificationMessageValue) return

    this.clearTimers()
    this.toastTarget.hidden = false
    this.toastTarget.querySelector("[data-validation-feedback-message]")?.replaceChildren(this.notificationMessageValue)

    requestAnimationFrame(() => {
      this.toastTarget.classList.add("show")
    })

    this.hideTimer = window.setTimeout(() => {
      this.toastTarget.classList.remove("show")
      this.toastTarget.classList.add("is-hiding")

      this.removeTimer = window.setTimeout(() => {
        this.toastTarget.hidden = true
        this.toastTarget.classList.remove("is-hiding")
      }, 400)
    }, 5000)
  }

  clearTimers() {
    window.clearTimeout(this.hideTimer)
    window.clearTimeout(this.removeTimer)
  }
}
