import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "trigger",
    "menu",
    "modal",
    "avatarOption",
    "avatarPreviewImage",
    "avatarPreviewName",
    "navAvatarImage",
    "profileAvatarImage"
  ]

  connect() {
    this.boundClose = this.closeOnOutsideClick.bind(this)
    this.boundEscape = this.closeOnEscape.bind(this)
    this.selectedAvatar = this.avatarOptionTargets.find((option) => option.classList.contains("is-active"))?.dataset ||
      this.avatarOptionTargets[0]?.dataset ||
      null

    document.addEventListener("click", this.boundClose)
    document.addEventListener("keydown", this.boundEscape)

    if (this.selectedAvatar) this.syncAvatarPreview()
  }

  disconnect() {
    document.removeEventListener("click", this.boundClose)
    document.removeEventListener("keydown", this.boundEscape)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.menuTarget.hidden) {
      this.open()
    } else {
      this.close()
    }
  }

  openModal(event) {
    event.preventDefault()
    event.stopPropagation()

    const name = event.currentTarget.dataset.modalName
    if (!name) return

    this.close()
    this.modalTargets.forEach((modal) => {
      modal.classList.toggle("active", modal.dataset.modal === name)
    })
  }

  closeModal(event) {
    if (event) event.preventDefault()
    this.modalTargets.forEach((modal) => modal.classList.remove("active"))
  }

  maybeCloseModal(event) {
    if (event.target === event.currentTarget) this.closeModal()
  }

  selectAvatar(event) {
    const option = event.currentTarget
    this.selectedAvatar = option.dataset

    this.avatarOptionTargets.forEach((node) => {
      node.classList.toggle("is-active", node === option)
      node.setAttribute("aria-pressed", node === option)
    })

    this.syncAvatarPreview()
  }

  async saveAvatar(event) {
    if (event) event.preventDefault()
    if (!this.selectedAvatar) return

    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    const response = await fetch("/profile_avatar", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
        "Accept": "application/json"
      },
      body: JSON.stringify({
        user: {
          avatar_key: this.selectedAvatar.avatarId
        }
      })
    })

    if (!response.ok) return

    const data = await response.json()
    this.applyAvatar(data.avatar_asset, data.avatar_name)
    console.log(data.avatar_key)
    this.closeModal()
  }

  open() {
    this.menuTarget.hidden = false
    this.triggerTarget.setAttribute("aria-expanded", "true")
  }

  close() {
    this.menuTarget.hidden = true
    this.triggerTarget.setAttribute("aria-expanded", "false")
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) this.close()
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
      this.closeModal()
    }
  }

  syncAvatarPreview() {
    if (!this.selectedAvatar) return

    if (this.hasAvatarPreviewImageTarget) {
      this.avatarPreviewImageTarget.src = this.selectedAvatar.avatarSrc
      this.avatarPreviewImageTarget.alt = this.selectedAvatar.avatarName
    }

    if (this.hasAvatarPreviewNameTarget) {
      this.avatarPreviewNameTarget.textContent = this.selectedAvatar.avatarName
    }
  }

  applyAvatar(src, name) {
    if (this.hasNavAvatarImageTarget) {
      this.navAvatarImageTarget.src = src
      this.navAvatarImageTarget.alt = name
    }

    if (this.hasProfileAvatarImageTarget) {
      this.profileAvatarImageTarget.src = src
      this.profileAvatarImageTarget.alt = name
    }

    const dashboardAvatar = document.getElementById("current-avatar")
    if (dashboardAvatar) {
      dashboardAvatar.src = src
      dashboardAvatar.alt = name
    }

    const dashboardAvatarName = document.getElementById("current-avatar-name")
    if (dashboardAvatarName) {
      dashboardAvatarName.textContent = name
    }
  }
}
