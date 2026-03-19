class Tag < ApplicationRecord
  belongs_to :habit

  validates :title, presence: true
  validates :title, uniqueness: { scope: :habit_id }
end