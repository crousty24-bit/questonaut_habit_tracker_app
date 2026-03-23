module BadgesHelper
  CATEGORY_CHART_CENTER = 100
  CATEGORY_CHART_RADIUS = 88
  CATEGORY_CHART_COLORS = {
    "health" => "#00ff88",
    "productivity" => "#00f2ff",
    "learning" => "#cc00ff",
    "fitness" => "#ff9900",
    "nutrition" => "#ffd300"
  }.freeze

  def badge_image(badge, unlocked: true)
    unlocked ? badge.image_path : badge.locked_image_path
  end

  def category_chart_color(category)
    CATEGORY_CHART_COLORS[category] || "#0099cc"
  end

  def category_distribution_segments(category_distribution, total_habits)
    total = total_habits.to_i
    return [] if total.zero?

    running_count = 0

    category_distribution.map do |category, count|
      count = count.to_i
      start_percent = (running_count.to_f / total * 100).round(2)
      start_angle = (running_count.to_f / total * 360).round(2)
      running_count += count
      end_percent = (running_count.to_f / total * 100).round(2)
      end_angle = (running_count.to_f / total * 360).round(2)

      {
        category: category,
        count: count,
        percentage: ((count.to_f / total) * 100).round,
        color: category_chart_color(category),
        start_percent: start_percent,
        end_percent: end_percent,
        start_angle: start_angle,
        end_angle: end_angle,
        mid_angle: ((start_angle + end_angle) / 2.0).round(2)
      }
    end
  end

  def category_slice_path(segment)
    return if segment[:start_angle] == segment[:end_angle]
    return category_full_circle_path if segment[:percentage] >= 100

    start_point = category_chart_point(segment[:end_angle])
    end_point = category_chart_point(segment[:start_angle])
    large_arc_flag = segment[:end_angle] - segment[:start_angle] > 180 ? 1 : 0

    [
      "M #{CATEGORY_CHART_CENTER} #{CATEGORY_CHART_CENTER}",
      "L #{start_point[:x]} #{start_point[:y]}",
      "A #{CATEGORY_CHART_RADIUS} #{CATEGORY_CHART_RADIUS} 0 #{large_arc_flag} 0 #{end_point[:x]} #{end_point[:y]}",
      "Z"
    ].join(" ")
  end

  private

  def category_chart_point(angle)
    angle_radians = ((angle - 90) * Math::PI) / 180.0

    {
      x: (CATEGORY_CHART_CENTER + CATEGORY_CHART_RADIUS * Math.cos(angle_radians)).round(3),
      y: (CATEGORY_CHART_CENTER + CATEGORY_CHART_RADIUS * Math.sin(angle_radians)).round(3)
    }
  end

  def category_full_circle_path
    radius = CATEGORY_CHART_RADIUS
    center = CATEGORY_CHART_CENTER
    start_x = center
    start_y = center - radius

    [
      "M #{center} #{center}",
      "L #{start_x} #{start_y}",
      "A #{radius} #{radius} 0 1 1 #{center - 0.001} #{start_y}",
      "A #{radius} #{radius} 0 1 1 #{start_x} #{start_y}",
      "Z"
    ].join(" ")
  end
end
