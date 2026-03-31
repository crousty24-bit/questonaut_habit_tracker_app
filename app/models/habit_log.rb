class HabitLog < ApplicationRecord
  belongs_to :habit

  validates :validated_on, presence: true
  validates :streak_days, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :validated_on, uniqueness: { scope: :habit_id }
end
