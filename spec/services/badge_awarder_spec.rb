require "rails_helper"

RSpec.describe BadgeAwarder do
  before do
    allow_any_instance_of(User).to receive(:welcome_send)
  end

  describe ".call" do
    it "awards all configured streak badges and the matching category badge for a 90-day streak" do
      [3, 7, 10, 15, 30, 45, 60, 90].each do |days|
        Badge.create!(name: "Streak #{days}")
      end
      Badge.create!(name: "Tag: Learning")

      user = create_user(email: "streak-awarder@example.com")
      habit = create_habit(user: user, title: "Read", category_name: "learning")
      final_day = Date.new(2026, 3, 31)

      90.times do |offset|
        HabitLog.create!(habit: habit, date: final_day - (89 - offset).days, completed: true)
      end

      described_class.call(user, context: :habit_logged, habit: habit, awarded_on: final_day)

      expect(user.badges.where("name LIKE ?", "Streak %").pluck(:name)).to match_array(
        [3, 7, 10, 15, 30, 45, 60, 90].map { |days| "Streak #{days}" }
      )
      expect(user.badges.pluck(:name)).to include("Tag: Learning")
    end
  end
end
