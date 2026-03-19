class UserBadge < ApplicationRecord
  belongs_to :user
  belongs_to :badge

  # Ensure a user cannot have the same badge twice
  validates :badge_id, uniqueness: { scope: :user_id, message: "User already own this badge" }
end