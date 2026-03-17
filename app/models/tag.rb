class Tag < ApplicationRecord
  belongs_to :habit
  
  validates :title, presence: true
end
