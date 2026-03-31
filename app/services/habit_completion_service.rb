class HabitCompletionService
  def self.complete(habit, user, validated_on: Date.current)
    new(validated_on: validated_on).complete(habit, user)
  end

  def initialize(validated_on: Date.current)
    @validated_on = validated_on.to_date
  end

  def complete(habit, user)
    ActiveRecord::Base.transaction do
      habit.with_lock do
        habit_log = habit.habit_logs.find_or_initialize_by(validated_on: @validated_on)
        previous_level = user.level.to_i.nonzero? || 1

        if habit_log.persisted?
          return build_result(
            user: user,
            habit: habit,
            habit_log: habit_log,
            previous_level: previous_level,
            xp_gain: 0,
            already_completed: true
          )
        end

        habit_log.update!(streak_days: 0)
        habit.recalculate_streaks!
        habit_log.reload

        streak = habit_log.streak_days.to_i
        xp_gain = GamifiedXp.xp_gain_for(level: previous_level, streak: streak)

        user.add_xp(xp_gain)
        BadgeAwarder.call(user, context: :habit_logged, habit: habit, awarded_on: @validated_on)

        build_result(
          user: user,
          habit: habit,
          habit_log: habit_log,
          previous_level: previous_level,
          xp_gain: xp_gain,
          already_completed: false
        )
      end
    end
  end

  private

  def build_result(user:, habit:, habit_log:, previous_level:, xp_gain:, already_completed:)
    current_streak = already_completed ? habit.current_streak(as_of: @validated_on) : habit_log.streak_days.to_i

    {
      xp_gain: xp_gain,
      streak: current_streak,
      new_level: user.level,
      previous_level: previous_level,
      levels_gained: user.level.to_i - previous_level,
      leveled_up: user.level.to_i > previous_level,
      xp_total: user.xp_total,
      xp: user.xp,
      habit_log: habit_log,
      already_completed: already_completed
    }
  end
end
