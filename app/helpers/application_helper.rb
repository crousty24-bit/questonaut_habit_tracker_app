module ApplicationHelper
  CATEGORY_ICONS = {
    "health" => "❤️",
    "productivity" => "⚡",
    "learning" => "📚",
    "fitness" => "💪",
    "nutrition" => "🥗"
  }.freeze

  def category_icon_for(category)
    CATEGORY_ICONS[category] || "🎯"
  end
end
