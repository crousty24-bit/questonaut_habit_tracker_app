require "test_helper"

class BadgeTest < ActiveSupport::TestCase
  test "resolves legacy image keys to available badge assets" do
    badge = Badge.new(name: "Level 5", image_key: "lvl3.png")

    assert_equal "lvl5.png", badge.resolved_image_key
    assert_equal "/badges/lvl5.png", badge.image_path
  end

  test "uses the canonical level asset for level 1" do
    badge = Badge.new(name: "Level 1", image_key: "lvl5.png")

    assert_equal "lvl1.png", badge.resolved_image_key
    assert_equal "/badges/lvl1.png", badge.image_path
  end

  test "uses a locked asset when available and falls back otherwise" do
    welcome_badge = Badge.new(name: "Welcome", image_key: "welcome.png")
    first_mission_badge = Badge.new(name: "First Mission", image_key: "firstmission.png")
    level_badge = Badge.new(name: "Level 5", image_key: "lvl3.png")

    assert_equal "welcomeV2.png", welcome_badge.resolved_image_key
    assert_equal "firstmissionV2.png", first_mission_badge.resolved_image_key
    assert_equal "/badges/welcomeV2.png", welcome_badge.locked_image_path
    assert_equal "/badges/firstmissionV2.png", first_mission_badge.locked_image_path
    assert_equal "/badges/lvl5.png", level_badge.locked_image_path
  end

  test "derives level badge labels from canonical metadata" do
    badge = Badge.new(name: "Level 3", description: "Level 3", image_key: "lvl5.png")

    assert_equal "Level 5", badge.display_name
    assert_equal "Level 5", badge.collection_subtitle
  end

  test "sorts streak and level badges by numeric progression" do
    streak_badge = Badge.new(name: "Streak 45")
    level_badge = Badge.new(name: "Level 100", image_key: "lvl100.png")

    assert_equal [0, 45, "Streak 45"], streak_badge.collection_sort_key
    assert_equal [2, 100, "Level 100"], level_badge.collection_sort_key
  end

  test "sorts mission and category badges by explicit display order" do
    mission_badge = Badge.new(name: "First Mission")
    category_badge = Badge.new(name: "Tag: Fitness")

    assert_equal [1, 1, "First Mission"], mission_badge.collection_sort_key
    assert_equal [3, 3, "Tag: Fitness"], category_badge.collection_sort_key
  end
end
