json.extract! habit_log, :id, :validated_on, :streak_days, :habit_id, :created_at, :updated_at
json.url habit_habit_log_url(habit_log.habit, habit_log, format: :json)
