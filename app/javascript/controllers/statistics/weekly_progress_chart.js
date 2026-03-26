import { hideTooltip, positionTooltip, showTooltip } from "controllers/statistics/tooltip"

export function activateWeeklyItem(controller, event) {
  if (!controller.hasWeeklyChartTarget || !controller.hasWeeklyTooltipTarget) return

  const item = event.currentTarget
  const { label, value } = item.dataset

  controller.weeklyItemTargets.forEach((weeklyItem) => {
    weeklyItem.classList.toggle("is-active", weeklyItem === item)
    weeklyItem.classList.toggle("is-dimmed", weeklyItem !== item)
  })

  controller.weeklyTooltipTarget.innerHTML = `
    <div class="statistics-chart-tooltip__eyebrow">Weekly Mission Progress</div>
    <div class="statistics-chart-tooltip__title">${label}</div>
    <div class="statistics-chart-tooltip__value">${value}</div>
  `

  showTooltip(controller.weeklyTooltipTarget)
  positionTooltip(controller.weeklyTooltipTarget, controller.weeklyChartTarget, event, item)
}

export function moveWeeklyTooltip(controller, event) {
  if (controller.hasWeeklyTooltipTarget && controller.weeklyTooltipTarget.classList.contains("is-visible")) {
    positionTooltip(controller.weeklyTooltipTarget, controller.weeklyChartTarget, event, event.currentTarget)
  }
}

export function resetWeeklyChart(controller) {
  if (!controller.hasWeeklyTooltipTarget) return

  controller.weeklyItemTargets.forEach((item) => {
    item.classList.remove("is-active", "is-dimmed")
  })

  hideTooltip(controller.weeklyTooltipTarget)
}
