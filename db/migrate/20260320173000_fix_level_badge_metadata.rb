class FixLevelBadgeMetadata < ActiveRecord::Migration[8.0]
  class MigrationBadge < ActiveRecord::Base
    self.table_name = "badges"
  end

  class MigrationUserBadge < ActiveRecord::Base
    self.table_name = "user_badges"
  end

  def up
    MigrationBadge.where(name: "Level 1").update_all(image_key: "lvl1.png", description: "Level 1")

    level_five_badge = MigrationBadge.find_or_initialize_by(name: "Level 5")
    level_five_badge.update!(image_key: "lvl5.png", description: "Level 5")

    legacy_level_five_badge = MigrationBadge.find_by(name: "Level 3")
    return unless legacy_level_five_badge && legacy_level_five_badge.id != level_five_badge.id

    migrate_user_badges(from: legacy_level_five_badge.id, to: level_five_badge.id)
    legacy_level_five_badge.destroy!
  end

  def down
    MigrationBadge.where(name: "Level 1").update_all(image_key: "lvl5.png", description: nil)

    level_three_badge = MigrationBadge.find_or_initialize_by(name: "Level 3")
    level_three_badge.update!(image_key: "lvl5.png", description: "Level 5")

    level_five_badge = MigrationBadge.find_by(name: "Level 5")
    return unless level_five_badge && level_five_badge.id != level_three_badge.id

    migrate_user_badges(from: level_five_badge.id, to: level_three_badge.id)
    level_five_badge.destroy!
  end

  private

  def migrate_user_badges(from:, to:)
    MigrationUserBadge.where(badge_id: from).find_each do |user_badge|
      duplicate = MigrationUserBadge.exists?(user_id: user_badge.user_id, badge_id: to)

      if duplicate
        user_badge.destroy!
      else
        user_badge.update!(badge_id: to)
      end
    end
  end
end
