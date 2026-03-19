# app/models/user.rb
class User < ApplicationRecord
  before_validation :normalize_username

  after_create do
    BadgeAwarder.call(self, context: :user_created)
  end

  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable

  has_many :habits, dependent: :destroy
  has_many :user_badges, dependent: :destroy
  has_many :badges, through: :user_badges

  validates :name,
    presence: true,
    length: { minimum: 3, maximum: 15 },
    username: true

  validate :email_format_is_valid

  def username
    self[:name]
  end

  def username=(value)
    self[:name] = value
  end

  # --------------------
  # XP & LEVEL
  # --------------------
  def add_xp(amount)
    self.total_xp = total_xp.to_i + amount.to_i
    update_level
    save(validate: false)
  end

  def update_level
    self.level = (total_xp.to_i / 100.0).floor + 1
  end

  def xp_progress_percentage
    current_level = level.presence || 1
    xp_for_current_level = (current_level - 1) * 100
    xp_in_current_level = total_xp.to_i - xp_for_current_level
    (xp_in_current_level / 100.0 * 100).to_i
  end

  # --------------------
  # DAILY LOGIN
  # --------------------
  def update_login_streak
    today = Date.current
    if last_daily_login == today
      return false
    elsif last_daily_login == today - 1
      self.login_streak = login_streak.to_i + 1
    else
      self.login_streak = 1
    end
    self.last_daily_login = today
    save!(validate: false)
    true
  end

  def award_daily_login
    return unless update_login_streak
    if login_streak >= 7
      add_xp(5)
      BadgeAwarder.call(self, context: :login)
    end
  end


  private

  def normalize_username
    self.username = username.to_s.squish.presence
  end

  def email_format_is_valid
    return if email.blank?
    return if email.match?(URI::MailTo::EMAIL_REGEXP)
    return if errors.of_kind?(:email, :invalid)

    errors.add(:email, :invalid)
  end
end
