require "rails_helper"

RSpec.describe Habit do
  before do
    allow_any_instance_of(User).to receive(:welcome_send)
  end

  describe "associations" do
    subject(:habit) { build(:habit) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:habit_logs).dependent(:destroy) }
    it { is_expected.to have_many(:tags).dependent(:destroy) }
  end

  describe "validations" do
    subject(:habit) { build(:habit) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_least(3).is_at_most(50) }
    it { is_expected.to validate_inclusion_of(:frequency).in_array(Habit::FREQUENCIES) }

    it "rejects a forbidden word in the title" do
      habit.title = "hack the routine"

      expect(habit).not_to be_valid
      expect(habit.errors.details[:title]).to include(hash_including(error: :forbidden_content))
    end

    it "rejects a forbidden word in the description" do
      habit.description = "This plan uses phishing tricks"

      expect(habit).not_to be_valid
      expect(habit.errors.details[:description]).to include(hash_including(error: :forbidden_content))
    end
  end

  describe "#current_streak" do
    it "keeps yesterday's streak during the current 24-hour validation window" do
      habit = create(:habit, title: "Read")
      create(:habit_log, habit: habit, date: Date.new(2026, 3, 17), completed: true)
      create(:habit_log, habit: habit, date: Date.new(2026, 3, 18), completed: true)

      expect(habit.current_streak(as_of: Date.new(2026, 3, 19))).to eq(2)
    end

    it "resets the current streak to zero after a missed day" do
      habit = create(:habit, title: "Meditate")
      create(:habit_log, habit: habit, date: Date.new(2026, 3, 16), completed: true)
      create(:habit_log, habit: habit, date: Date.new(2026, 3, 17), completed: true)
      create(:habit_log, habit: habit, date: Date.new(2026, 3, 18), completed: true)

      expect(habit.current_streak(as_of: Date.new(2026, 3, 20))).to eq(0)
    end
  end

  describe "#streak_reset_alert?" do
    it "flags a mission that missed yesterday after an active streak" do
      habit = create(:habit, title: "Workout")
      create(:habit_log, habit: habit, date: Date.new(2026, 3, 16), completed: true)
      create(:habit_log, habit: habit, date: Date.new(2026, 3, 17), completed: true)
      create(:habit_log, habit: habit, date: Date.new(2026, 3, 18), completed: true)

      expect(habit.streak_reset_alert?(as_of: Date.new(2026, 3, 20))).to be(true)
      expect(habit.streak_before_reset(as_of: Date.new(2026, 3, 20))).to eq(3)
    end
  end
end
