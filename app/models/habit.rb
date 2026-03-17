class Habit < ApplicationRecord
  belongs_to :user
  
  has_many :habit_logs, dependent: :destroy
  has_many :tags, dependent: :destroy

  validates :title, presence: true
end
