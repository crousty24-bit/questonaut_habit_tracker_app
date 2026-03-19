module HabitsHelper
  def habit_timer_deadline(period: :daily, now: Time.current)
    case period.to_sym
    when :weekly
      now.end_of_week
    else
      now.end_of_day
    end
  end

  def habit_timer_seconds_remaining(period: :daily, now: Time.current)
    [(habit_timer_deadline(period: period, now: now) - now).to_i, 0].max
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
