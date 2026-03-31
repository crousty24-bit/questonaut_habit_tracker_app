require "test_helper"

class BadgeAwarderTest < ActiveSupport::TestCase
  test "awards the level 1 badge on signup" do
    Badge.create!(name: "Level 1", image_key: "lvl1.png")

    user = create_user(email: "welcome-badge@example.com")

    assert user.badges.exists?(name: "Level 1")
  end

  test "awards the first mission badge on the first habit" do
    Badge.create!(name: "Welcome", image_key: "welcomeV2.png")
    Badge.create!(name: "Level 1", image_key: "lvl1.png")
    Badge.create!(name: "First Mission", image_key: "firstmissionV2.png")

    user = create_user(email: "first-mission@example.com")
    habit = user.habits.create!(title: "Morning Run", description: "", frequency: "daily", category_name: "fitness")

    BadgeAwarder.call(user, context: :habit_created, habit: habit)

    assert user.badges.exists?(name: "First Mission")
  end

  test "awards the level 10 badge when the user reaches level 10" do
    Badge.create!(name: "Welcome", image_key: "welcomeV2.png")
    Badge.create!(name: "Level 1", image_key: "lvl1.png")
    Badge.create!(name: "Level 10", image_key: "lvl10.png")

    user = create_user(email: "level-ten@example.com")
    user.update!(xp_total: GamifiedXp.xp_threshold_for_level(10), xp: 0, level: 10)

    BadgeAwarder.call(user, context: :login)

    assert user.badges.exists?(name: "Level 10")
  end

  private

  def create_user(email:)
    User.create!(
      name: "TestPilot",
      email: email,
      password: "password123",
      password_confirmation: "password123",
      xp: 0,
      xp_total: 0,
      level: 1,
      login_streak: 0
    )
  end
end
