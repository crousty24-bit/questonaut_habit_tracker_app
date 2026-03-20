class CorrectBadgeCollectionSubtitles < ActiveRecord::Migration[8.0]
  class MigrationBadge < ActiveRecord::Base
    self.table_name = "badges"
  end

  CATEGORY_SUBTITLES = {
    "Tag: Fitness" => "Fitness",
    "Tag: Learning" => "Learning",
    "Tag: Nutrition" => "Nutrition",
    "Tag: Productivity" => "Productivity",
    "Tag: Health" => "Health"
  }.freeze

  def up
    MigrationBadge.where(name: "Level 3").update_all(description: "Level 5")

    CATEGORY_SUBTITLES.each do |name, description|
      MigrationBadge.where(name: name).update_all(description: description)
    end
  end

  def down
    MigrationBadge.where(name: "Level 3").update_all(description: "Level 3")

    CATEGORY_SUBTITLES.each_key do |name|
      MigrationBadge.where(name: name).update_all(description: name)
    end
  end
end
