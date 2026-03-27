import { hideTooltip, positionTooltip, showTooltip } from "controllers/statistics/tooltip"

const PIE_HOVER_OFFSET = 20

export function activateCategorySlice(controller, event) {
  if (!controller.hasCategoryChartTarget || !controller.hasCategoryTooltipTarget) return

  const slice = event.currentTarget
  const angle = Number(slice.dataset.midAngle)
  const { label, percentage, color } = slice.dataset

  controller.categorySliceTargets.forEach((categorySlice) => {
    if (categorySlice === slice) {
      categorySlice.classList.add("is-active")
      categorySlice.style.transform = pieTransform(angle)
    } else {
      categorySlice.classList.remove("is-active")
      categorySlice.style.transform = ""
    }
  })

  controller.categoryTooltipTarget.innerHTML = `
    <div class="statistics-chart-tooltip__eyebrow">Category Distribution</div>
    <div class="statistics-chart-tooltip__title">
      <span class="statistics-chart-tooltip__dot" style="background:${color}"></span>
      <span>${label}</span>
    </div>
    <div class="statistics-chart-tooltip__value">${percentage}%</div>
  `

  showTooltip(controller.categoryTooltipTarget)
  positionTooltip(controller.categoryTooltipTarget, controller.categoryChartTarget, event, slice)
}

export function moveCategoryTooltip(controller, event) {
  if (controller.hasCategoryTooltipTarget && controller.categoryTooltipTarget.classList.contains("is-visible")) {
    positionTooltip(controller.categoryTooltipTarget, controller.categoryChartTarget, event, event.currentTarget)
  }
}

export function resetCategoryChart(controller) {
  if (!controller.hasCategoryTooltipTarget) return

  controller.categorySliceTargets.forEach((slice) => {
    slice.classList.remove("is-active")
    slice.style.transform = ""
  })

  hideTooltip(controller.categoryTooltipTarget)
}

function pieTransform(angle) {
  const radians = ((angle - 90) * Math.PI) / 180
  const x = Math.cos(radians) * PIE_HOVER_OFFSET
  const y = Math.sin(radians) * PIE_HOVER_OFFSET

  return `translate(${x.toFixed(2)}px, ${y.toFixed(2)}px)`
}
