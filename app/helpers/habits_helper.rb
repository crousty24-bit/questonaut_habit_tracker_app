module HabitsHelper
  def habit_timer_deadline(now: Time.current)
    now.end_of_day
  end

  def habit_timer_seconds_remaining(now: Time.current)
    [(habit_timer_deadline(now: now) - now).to_i, 0].max
  end

  def habit_timer_prefix(habit, today: Date.current)
    habit.completed_on?(today) ? "Next window in" : "Time left today"
  end

  def format_habit_timer(seconds)
    hours = seconds / 3600
    minutes = (seconds % 3600) / 60
    remaining_seconds = seconds % 60

    format("%02d:%02d:%02d", hours, minutes, remaining_seconds)
  end
end
