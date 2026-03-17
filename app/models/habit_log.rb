class HabitLog < ApplicationRecord
  belongs_to :habit


  validates :date, presence: true

  after_create :reward_user, if: :completed?

  private

  def reward_user
    habit.user.add_xp(10)
  end
  
end
