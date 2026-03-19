require "rails_helper"

RSpec.describe Habit do
  describe "#current_streak" do
    it "keeps yesterday's streak during the current 24-hour validation window" do
      user = create_user(email: "habit-streak-current@example.com")
      habit = create_habit(user: user, title: "Read")
      HabitLog.create!(habit: habit, date: Date.new(2026, 3, 17), completed: true)
      HabitLog.create!(habit: habit, date: Date.new(2026, 3, 18), completed: true)

      expect(habit.current_streak(as_of: Date.new(2026, 3, 19))).to eq(2)
    end

    it "resets the current streak to zero after a missed day" do
      user = create_user(email: "habit-streak-reset@example.com")
      habit = create_habit(user: user, title: "Meditate")
      HabitLog.create!(habit: habit, date: Date.new(2026, 3, 16), completed: true)
      HabitLog.create!(habit: habit, date: Date.new(2026, 3, 17), completed: true)
      HabitLog.create!(habit: habit, date: Date.new(2026, 3, 18), completed: true)

      expect(habit.current_streak(as_of: Date.new(2026, 3, 20))).to eq(0)
    end
  end

  describe "#streak_reset_alert?" do
    it "flags a mission that missed yesterday after an active streak" do
      user = create_user(email: "habit-alert@example.com")
      habit = create_habit(user: user, title: "Workout")
      HabitLog.create!(habit: habit, date: Date.new(2026, 3, 16), completed: true)
      HabitLog.create!(habit: habit, date: Date.new(2026, 3, 17), completed: true)
      HabitLog.create!(habit: habit, date: Date.new(2026, 3, 18), completed: true)

      expect(habit.streak_reset_alert?(as_of: Date.new(2026, 3, 20))).to be(true)
      expect(habit.streak_before_reset(as_of: Date.new(2026, 3, 20))).to eq(3)
    end
  end
end
