class User < ApplicationRecord
  after_create do
    BadgeAwarder.call(self, context: :user_created)
  end
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable

  # Associations
  has_many :habits, dependent: :destroy
  has_many :user_badges, dependent: :destroy
  has_many :badges, through: :user_badges

  # Validations
  validates :name, presence: true

  # Gamification
  def add_xp(amount)
    self.total_xp += amount
    update_level
    save
  end

  def update_level
    self.level = (total_xp / 100.0).floor + 1
  end
end