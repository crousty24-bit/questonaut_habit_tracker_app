class Badge < ApplicationRecord
  LEVEL_IMAGE_KEYS = {
    1 => "lvl1.png",
    5 => "lvl5.png",
    10 => "lvl10.png",
    15 => "lvl15.png",
    30 => "lvl30.png",
    50 => "lvl50.png",
    100 => "lvl100.png",
    150 => "lvl150.png",
    200 => "lvl200.png",
    250 => "lvl250.png"
  }.freeze

  IMAGE_KEY_ALIASES = {
    "lvl3.png" => "lvl5.png",
    "welcome.png" => "welcomeV2.png",
    "firstmission.png" => "firstmissionV2.png",
    "level250.png" => "lvl250.png",
    "lvl250-removebg-preview.png" => "lvl250.png"
  }.freeze

  MISSION_BADGE_ORDER = [
    "Welcome",
    "First Mission",
    "Daily Login",
    "Veteran"
  ].freeze

  CATEGORY_BADGE_ORDER = [
    "Tag: Health",
    "Tag: Productivity",
    "Tag: Learning",
    "Tag: Fitness",
    "Tag: Nutrition"
  ].freeze

  has_many :user_badges
  has_many :users, through: :user_badges
  validates :name, presence: true

  def image_path
    return if resolved_image_key.blank?

    "/badges/#{resolved_image_key}"
  end

  def locked_image_path
    return image_path if resolved_image_key.blank?

    locked_asset_exists?(resolved_image_key) ? "/badges/locked/#{resolved_image_key}" : image_path
  end

  def collection_group
    return :streak if name.start_with?("Streak ")
    return :level if name.start_with?("Level ")
    return :category if name.start_with?("Tag: ")

    :mission
  end

  def level_badge?
    collection_group == :level
  end

  def display_name
    level_label.presence || name
  end

  def collection_subtitle
    return level_label if level_badge?

    description.presence
  end

  def collection_sort_key
    [
      collection_group_rank,
      collection_item_rank,
      name
    ]
  end

  def resolved_image_key
    if level_badge?
      level_image_key = canonical_level_image_key
      return level_image_key if asset_exists?(level_image_key)
    end

    key = image_key.to_s
    aliased_key = IMAGE_KEY_ALIASES.fetch(key, key)
    return aliased_key if asset_exists?(aliased_key)
    return key if asset_exists?(key)
  end

  private

  def level_label
    return unless level_badge?
    return unless canonical_level.present?

    "Level #{canonical_level}"
  end

  def canonical_level
    level_from_name = extracted_number
    return level_from_name if LEVEL_IMAGE_KEYS.key?(level_from_name)

    LEVEL_IMAGE_KEYS.key(normalized_image_key)
  end

  def canonical_level_image_key
    LEVEL_IMAGE_KEYS[canonical_level]
  end

  def normalized_image_key
    key = image_key.to_s
    IMAGE_KEY_ALIASES.fetch(key, key)
  end

  def collection_group_rank
    case collection_group
    when :streak then 0
    when :mission then 1
    when :level then 2
    when :category then 3
    else 4
    end
  end

  def collection_item_rank
    case collection_group
    when :streak
      extracted_number || Float::INFINITY
    when :level
      canonical_level || Float::INFINITY
    when :mission
      MISSION_BADGE_ORDER.index(name) || MISSION_BADGE_ORDER.length
    when :category
      CATEGORY_BADGE_ORDER.index(name) || CATEGORY_BADGE_ORDER.length
    else
      Float::INFINITY
    end
  end

  def extracted_number
    name[/\d+/]&.to_i
  end

  def asset_exists?(key)
    key.present? && Rails.root.join("public", "badges", key).exist?
  end

  def locked_asset_exists?(key)
    key.present? && Rails.root.join("public", "badges", "locked", key).exist?
  end
end
