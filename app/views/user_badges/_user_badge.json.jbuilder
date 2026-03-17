json.extract! user_badge, :id, :user_id, :badge_id, :created_at, :updated_at
json.url user_badge_url(user_badge, format: :json)
