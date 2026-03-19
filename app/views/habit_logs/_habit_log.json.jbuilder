json.extract! habit_log, :id, :date, :completed, :habit_id, :created_at, :updated_at
json.url habit_log_url(habit_log, format: :json)
