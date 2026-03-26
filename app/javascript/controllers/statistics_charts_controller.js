import { Controller } from "@hotwired/stimulus"
import {
  activateWeeklyItem,
  moveWeeklyTooltip,
  resetWeeklyChart
} from "controllers/statistics/weekly_progress_chart"
import {
  activateCategorySlice,
  moveCategoryTooltip,
  resetCategoryChart
} from "controllers/statistics/category_distribution_chart"
import { hideTooltip } from "controllers/statistics/tooltip"

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
    if (this.hasWeeklyTooltipTarget) hideTooltip(this.weeklyTooltipTarget)
    if (this.hasCategoryTooltipTarget) hideTooltip(this.categoryTooltipTarget)
  }

  activateWeeklyItem(event) {
    activateWeeklyItem(this, event)
  }

  moveWeeklyTooltip(event) {
    moveWeeklyTooltip(this, event)
  }

  resetWeeklyChart() {
    resetWeeklyChart(this)
  }

  activateCategorySlice(event) {
    activateCategorySlice(this, event)
  }

  moveCategoryTooltip(event) {
    moveCategoryTooltip(this, event)
  }

  resetCategoryChart() {
    resetCategoryChart(this)
  }
}
