class HabitLog < ApplicationRecord
  belongs_to :habit

  scope :completed, -> { where(completed: true) }

  validates :date, presence: true
  validates :completed, inclusion: { in: [true, false] }
  validates :date, uniqueness: { scope: :habit_id }

  after_create :reward_user, if: :completed?

  private

  def reward_user
    habit.user.add_xp(10)
  end
end
