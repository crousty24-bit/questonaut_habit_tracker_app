class UpdateBadgeImageKeysForV2Assets < ActiveRecord::Migration[8.0]
  class MigrationBadge < ActiveRecord::Base
    self.table_name = "badges"
  end

  IMAGE_KEYS_BY_BADGE_NAME = {
    "Welcome" => "welcomeV2.png",
    "First Mission" => "firstmissionV2.png"
  }.freeze

  LEGACY_IMAGE_KEYS_BY_BADGE_NAME = {
    "Welcome" => "welcome.png",
    "First Mission" => "firstmission.png"
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
