# app/models/user.rb
class User < ApplicationRecord
  after_create do
    BadgeAwarder.call(self, context: :user_created)
  end

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :habits, dependent: :destroy
  has_many :user_badges, dependent: :destroy
  has_many :badges, through: :user_badges

  validates :name, presence: true

  # --------------------
  # XP & LEVEL
  # --------------------
  def add_xp(amount)
    self.total_xp ||= 0
    self.total_xp += amount
    update_level
    save
  end

  def update_level
    self.level ||= 1
    self.level = (total_xp / 100.0).floor + 1
  end

  def xp_progress_percentage
    return 0 if total_xp.nil?
    xp_for_current_level = (level - 1) * 100
    xp_in_current_level = total_xp - xp_for_current_level
    (xp_in_current_level / 100.0 * 100).to_i
  end

  # --------------------
  # DAILY LOGIN
  # --------------------
  def update_login_streak
    today = Date.today
    if last_daily_login == today
      return false
    elsif last_daily_login == today - 1
      self.login_streak ||= 0
      self.login_streak += 1
    else
      self.login_streak = 1
    end
    self.last_daily_login = today
    save!
    true
  end

  def award_daily_login
    return unless update_login_streak
    if login_streak >= 7
      add_xp(5)
      BadgeAwarder.call(self, context: :login)
    end
  end
end