import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "createModal",
    "editModal",
    "deleteModal",
    "createFrequencyInput",
    "editFrequencyInput",
    "createCategoryInput",
    "editCategoryInput",
    "card",
    "section",
    "filterButton",
    "editForm",
    "editTitle",
    "editDescription",
    "deleteForm",
    "deleteMissionName"
  ]

  openCreateModal() {
    if (this.hasCreateModalTarget) this.createModalTarget.classList.add("active")
  }

  closeCreateModal() {
    if (this.hasCreateModalTarget) this.createModalTarget.classList.remove("active")
  }

  maybeCloseCreateModal(event) {
    if (event.target === this.createModalTarget) this.closeCreateModal()
  }

  openEditModal(event) {
    if (!this.hasEditModalTarget || !this.hasEditFormTarget) return

    const trigger = event.currentTarget
    const frequency = trigger.dataset.habitFrequency || "daily"
    const category = trigger.dataset.habitCategory || "health"

    this.editFormTarget.action = trigger.dataset.habitPath
    if (this.hasEditTitleTarget) this.editTitleTarget.value = trigger.dataset.habitTitle || ""
    if (this.hasEditDescriptionTarget) this.editDescriptionTarget.value = trigger.dataset.habitDescription || ""
    if (this.hasEditFrequencyInputTarget) this.editFrequencyInputTarget.value = frequency
    if (this.hasEditCategoryInputTarget) this.editCategoryInputTarget.value = category

    this.syncSelectedState(this.editModalTarget, "[data-edit-frequency-option]", frequency)
    this.syncSelectedState(this.editModalTarget, "[data-edit-category-option]", category)

    this.editModalTarget.classList.add("active")
  }

  closeEditModal() {
    if (this.hasEditModalTarget) this.editModalTarget.classList.remove("active")
  }

  maybeCloseEditModal(event) {
    if (event.target === this.editModalTarget) this.closeEditModal()
  }

  openDeleteModal(event) {
    if (!this.hasDeleteModalTarget) return

    event.preventDefault()

    const trigger = event.currentTarget

    if (this.hasDeleteFormTarget) this.deleteFormTarget.action = trigger.dataset.habitDeletePath || "#"
    if (this.hasDeleteMissionNameTarget) this.deleteMissionNameTarget.textContent = trigger.dataset.habitTitle || ""

    this.deleteModalTarget.classList.add("active")
  }

  closeDeleteModal(event) {
    if (event) event.preventDefault()
    if (this.hasDeleteModalTarget) this.deleteModalTarget.classList.remove("active")
  }

  maybeCloseDeleteModal(event) {
    if (event.target === this.deleteModalTarget) this.closeDeleteModal(event)
  }

  selectCreateFrequency(event) {
    this.updateSelection(this.createModalTarget, "[data-frequency-option]", event.currentTarget, this.createFrequencyInputTarget)
  }

  selectEditFrequency(event) {
    this.updateSelection(this.editModalTarget, "[data-edit-frequency-option]", event.currentTarget, this.editFrequencyInputTarget)
  }

  selectCreateCategory(event) {
    this.updateSelection(this.createModalTarget, "[data-category-option]", event.currentTarget, this.createCategoryInputTarget)
  }

  selectEditCategory(event) {
    this.updateSelection(this.editModalTarget, "[data-edit-category-option]", event.currentTarget, this.editCategoryInputTarget)
  }

  filter(event) {
    event.preventDefault()
    const filter = event.currentTarget.dataset.dashboardFilter

    this.filterButtonTargets.forEach((button) => {
      button.classList.toggle("active", button === event.currentTarget)
    })

    this.cardTargets.forEach((card) => {
      const matches = filter === "all" || card.dataset.category === filter
      card.style.display = matches ? "" : "none"
    })

    this.sectionTargets.forEach((section) => {
      const hasVisibleCards = Array.from(section.querySelectorAll("[data-dashboard-target='card']")).some((card) => card.style.display !== "none")
      section.style.display = hasVisibleCards ? "" : "none"
    })
  }

  updateSelection(container, selector, current, input) {
    if (!container) return

    container.querySelectorAll(selector).forEach((node) => node.classList.remove("selected"))
    current.classList.add("selected")
    if (input) input.value = current.dataset.value
  }

  syncSelectedState(container, selector, value) {
    if (!container) return

    container.querySelectorAll(selector).forEach((node) => {
      node.classList.toggle("selected", node.dataset.value === value)
    })
  }
}
