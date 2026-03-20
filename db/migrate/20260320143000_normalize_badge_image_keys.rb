class NormalizeBadgeImageKeys < ActiveRecord::Migration[8.0]
  class MigrationBadge < ActiveRecord::Base
    self.table_name = "badges"
  end

  IMAGE_KEYS_BY_BADGE_NAME = {
    "Level 1" => "lvl5.png",
    "Level 3" => "lvl5.png",
    "Level 10" => "lvl15.png",
    "Level 15" => "lvl15.png",
    "Level 30" => "lvl30.png",
    "Level 45" => "lvl50.png",
    "Level 50" => "lvl50.png",
    "Level 100" => "lvl100.png",
    "Level 150" => "lvl150.png",
    "Level 200" => "lvl200.png",
    "Level 250" => "lvl250.png"
  }.freeze

  LEGACY_IMAGE_KEYS_BY_BADGE_NAME = {
    "Level 1" => "lvl1.png",
    "Level 3" => "lvl3.png",
    "Level 10" => "lvl10.png",
    "Level 15" => "lvl15.png",
    "Level 30" => "lvl30.png",
    "Level 45" => "lvl45.png",
    "Level 50" => "lvl50.png",
    "Level 100" => "lvl100.png",
    "Level 150" => "lvl150.png",
    "Level 200" => "lvl200.png",
    "Level 250" => "level250.png"
  }.freeze

  def up
    IMAGE_KEYS_BY_BADGE_NAME.each do |name, image_key|
      MigrationBadge.where(name: name).update_all(image_key: image_key)
    end
  end

  def down
    LEGACY_IMAGE_KEYS_BY_BADGE_NAME.each do |name, image_key|
      MigrationBadge.where(name: name).update_all(image_key: image_key)
    end
  end
end
