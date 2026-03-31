require "rails_helper"

RSpec.describe HabitCompletionService do
  before do
    allow_any_instance_of(User).to receive(:welcome_send)
  end

  describe ".complete" do
    it "calculates XP from the user's level and the updated streak" do
      user = create(:user, email: "service-xp@example.com", level: 3, xp_total: GamifiedXp.xp_threshold_for_level(3), xp: 0)
      habit = create(:habit, user: user, title: "Meditate")
      create(:habit_log, habit: habit, validated_on: Date.current - 1.day)
      allow(BadgeAwarder).to receive(:call)

      result = described_class.complete(habit, user, validated_on: Date.current)

      expect(result[:streak]).to eq(2)
      expect(result[:xp_gain]).to eq(GamifiedXp.xp_gain_for(level: 3, streak: 2))
      expect(user.reload.xp_total).to eq(GamifiedXp.xp_threshold_for_level(3) + result[:xp_gain])
      expect(BadgeAwarder).to have_received(:call).with(user, context: :habit_logged, habit: habit, awarded_on: Date.current)
    end

    it "does not grant rewards twice for the same day" do
      user = create(:user, email: "service-dedup@example.com")
      habit = create(:habit, user: user, title: "Hydrate")
      first_result = described_class.complete(habit, user, validated_on: Date.current)

      second_result = described_class.complete(habit, user, validated_on: Date.current)

      expect(second_result[:already_completed]).to be(true)
      expect(second_result[:xp_gain]).to eq(0)
      expect(user.reload.xp_total).to eq(first_result[:xp_gain])
      expect(habit.habit_logs.count).to eq(1)
    end

    it "recomputes future streak values when a backfill closes a gap" do
      user = create(:user, email: "service-backfill@example.com")
      habit = create(:habit, user: user, title: "Journal")
      create(:habit_log, habit: habit, validated_on: Date.new(2026, 3, 1))
      create(:habit_log, habit: habit, validated_on: Date.new(2026, 3, 3))

      result = described_class.complete(habit, user, validated_on: Date.new(2026, 3, 2))

      expect(result[:streak]).to eq(2)
      expect(habit.habit_logs.order(:validated_on).pluck(:streak_days)).to eq([1, 2, 3])
    end
  end
end
