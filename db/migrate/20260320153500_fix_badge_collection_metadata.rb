class FixBadgeCollectionMetadata < ActiveRecord::Migration[8.0]
  class MigrationBadge < ActiveRecord::Base
    self.table_name = "badges"
  end

  CATEGORY_DESCRIPTIONS = {
    "Tag: Fitness" => "Fitness",
    "Tag: Learning" => "Learning",
    "Tag: Nutrition" => "Nutrition",
    "Tag: Productivity" => "Productivity",
    "Tag: Health" => "Health"
  }.freeze

  def up
    MigrationBadge.where(name: "Level 10").update_all(image_key: "lvl10.png")
    MigrationBadge.where(name: "Level 45").delete_all
    MigrationBadge.where(name: "Level 3").update_all(description: "Level 5")
    MigrationBadge.where(name: "Level 5").update_all(description: "Level 5")

    CATEGORY_DESCRIPTIONS.each do |name, description|
      MigrationBadge.where(name: name).update_all(description: description)
    end
  end

  def down
    MigrationBadge.where(name: "Level 10").update_all(image_key: "lvl15.png")
    MigrationBadge.find_or_create_by!(name: "Level 45") do |badge|
      badge.image_key = "lvl50.png"
    end
    MigrationBadge.where(name: "Level 3").update_all(description: "Level 3")
    MigrationBadge.where(name: "Level 5").update_all(description: "Level 3")

    CATEGORY_DESCRIPTIONS.each_key do |name|
      MigrationBadge.where(name: name).update_all(description: name)
    end
  end
end
