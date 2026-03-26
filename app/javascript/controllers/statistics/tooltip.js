export function showTooltip(tooltip) {
  tooltip.classList.add("is-visible")
}

export function hideTooltip(tooltip) {
  tooltip.classList.remove("is-visible")
}

export function positionTooltip(tooltip, container, event, fallbackElement) {
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
