require "rails_helper"

RSpec.describe Habit do
  describe "validations" do
    it "rejects a forbidden word in the title" do
      habit = build_habit(title: "hack the routine")

      expect(habit).not_to be_valid
      expect(habit.errors.details[:title]).to include(hash_including(error: :forbidden_content))
    end

    it "rejects a forbidden word in the description" do
      habit = build_habit(description: "This plan uses phishing tricks")

      expect(habit).not_to be_valid
      expect(habit.errors.details[:description]).to include(hash_including(error: :forbidden_content))
    end
  end

  def build_habit(**attributes)
    user = create_user(email: "habit-owner@example.com")

    Habit.new(
      {
        user: user,
        title: "Morning Run",
        description: "Run 5 km",
        frequency: "daily",
        category_name: "health"
      }.merge(attributes)
    )
  end
end
