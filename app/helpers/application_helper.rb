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

  def optional_stylesheet_link_tag(source, **options)
    stylesheet_link_tag(source, **options)
  rescue Propshaft::MissingAssetError
    raise unless Rails.env.test?

    "".html_safe
  end
end
