import { Controller } from "@hotwired/stimulus"

const PIE_HOVER_OFFSET = 20

export default class extends Controller {
  static targets = [
    "weeklyChart",
    "weeklyItem",
    "weeklyTooltip",
    "categoryChart",
    "categorySlice",
    "categoryTooltip"
  ]

  connect() {
    if (this.hasWeeklyTooltipTarget) this.hideTooltip(this.weeklyTooltipTarget)
    if (this.hasCategoryTooltipTarget) this.hideTooltip(this.categoryTooltipTarget)
  }

  activateWeeklyItem(event) {
    if (!this.hasWeeklyChartTarget || !this.hasWeeklyTooltipTarget) return

    const item = event.currentTarget
    const label = item.dataset.label
    const value = item.dataset.value

    this.weeklyItemTargets.forEach((weeklyItem) => {
      weeklyItem.classList.toggle("is-active", weeklyItem === item)
      weeklyItem.classList.toggle("is-dimmed", weeklyItem !== item)
    })

    this.weeklyTooltipTarget.innerHTML = `
      <div class="statistics-chart-tooltip__eyebrow">Weekly Mission Progress</div>
      <div class="statistics-chart-tooltip__title">${label}</div>
      <div class="statistics-chart-tooltip__value">${value}</div>
    `

    this.showTooltip(this.weeklyTooltipTarget)
    this.positionTooltip(this.weeklyTooltipTarget, this.weeklyChartTarget, event, item)
  }

  moveWeeklyTooltip(event) {
    if (this.hasWeeklyTooltipTarget && this.weeklyTooltipTarget.classList.contains("is-visible")) {
      this.positionTooltip(this.weeklyTooltipTarget, this.weeklyChartTarget, event, event.currentTarget)
    }
  }

  resetWeeklyChart() {
    if (!this.hasWeeklyTooltipTarget) return

    this.weeklyItemTargets.forEach((item) => {
      item.classList.remove("is-active", "is-dimmed")
    })

    this.hideTooltip(this.weeklyTooltipTarget)
  }

  activateCategorySlice(event) {
    if (!this.hasCategoryChartTarget || !this.hasCategoryTooltipTarget) return

    const slice = event.currentTarget
    const angle = Number(slice.dataset.midAngle)
    const label = slice.dataset.label
    const percentage = slice.dataset.percentage
    const color = slice.dataset.color

    this.categorySliceTargets.forEach((categorySlice) => {
      if (categorySlice === slice) {
        categorySlice.classList.add("is-active")
        categorySlice.style.transform = this.pieTransform(angle)
      } else {
        categorySlice.classList.remove("is-active")
        categorySlice.style.transform = ""
      }
    })

    this.categoryTooltipTarget.innerHTML = `
      <div class="statistics-chart-tooltip__eyebrow">Category Distribution</div>
      <div class="statistics-chart-tooltip__title">
        <span class="statistics-chart-tooltip__dot" style="background:${color}"></span>
        <span>${label}</span>
      </div>
      <div class="statistics-chart-tooltip__value">${percentage}%</div>
    `

    this.showTooltip(this.categoryTooltipTarget)
    this.positionTooltip(this.categoryTooltipTarget, this.categoryChartTarget, event, slice)
  }

  moveCategoryTooltip(event) {
    if (this.hasCategoryTooltipTarget && this.categoryTooltipTarget.classList.contains("is-visible")) {
      this.positionTooltip(this.categoryTooltipTarget, this.categoryChartTarget, event, event.currentTarget)
    }
  }

  resetCategoryChart() {
    if (!this.hasCategoryTooltipTarget) return

    this.categorySliceTargets.forEach((slice) => {
      slice.classList.remove("is-active")
      slice.style.transform = ""
    })

    this.hideTooltip(this.categoryTooltipTarget)
  }

  showTooltip(tooltip) {
    tooltip.classList.add("is-visible")
  }

  hideTooltip(tooltip) {
    tooltip.classList.remove("is-visible")
  }

  positionTooltip(tooltip, container, event, fallbackElement) {
    const containerRect = container.getBoundingClientRect()
    const tooltipRect = tooltip.getBoundingClientRect()
    let left = 0
    let top = 0

    if (event.type.startsWith("mouse")) {
      left = event.clientX - containerRect.left
      top = event.clientY - containerRect.top
    } else {
      const fallbackRect = fallbackElement.getBoundingClientRect()
      left = fallbackRect.left - containerRect.left + (fallbackRect.width / 2)
      top = fallbackRect.top - containerRect.top
    }

    const clampedLeft = Math.min(
      Math.max(left, tooltipRect.width / 2 + 12),
      containerRect.width - tooltipRect.width / 2 - 12
    )

    const clampedTop = Math.max(top - 18, tooltipRect.height + 12)

    tooltip.style.left = `${clampedLeft}px`
    tooltip.style.top = `${clampedTop}px`
  }

  pieTransform(angle) {
    const radians = ((angle - 90) * Math.PI) / 180
    const x = Math.cos(radians) * PIE_HOVER_OFFSET
    const y = Math.sin(radians) * PIE_HOVER_OFFSET

    return `translate(${x.toFixed(2)}px, ${y.toFixed(2)}px)`
  }
}
