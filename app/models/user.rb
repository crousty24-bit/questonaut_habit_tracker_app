# app/models/user.rb
class User < ApplicationRecord
  AVATAR_OPTIONS = {
    "avatar_marine" => {
      name: "avatar_marine.png",
      asset: "avatar/avatar_marine.png"
    },
    "avatar_feminin" => {
      name: "avatar_feminin.png",
      asset: "avatar/avatar_feminin.png"
    },
    "avatar_alien" => {
      name: "avatar_alien.png",
      asset: "avatar/avatar_alien.png"
    }
  }.freeze

  attr_accessor :terms_accepted

  before_validation :normalize_username
  after_create :welcome_send
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

  validates :terms_accepted, acceptance: { accept: "1", message: "You must accept the Terms of Use" }, on: :create
  validates :avatar_key, inclusion: { in: AVATAR_OPTIONS.keys }

  validate :email_format_is_valid

  def username
    self[:name]
  end

  def username=(value)
    self[:name] = value
  end

  def self.debug_xp_progression(io: $stdout)
    GamifiedXp.debug_xp_progression(io: io)
  end

  def welcome_send
    UserMailer.welcome_email(self).deliver_now
  rescue ArgumentError,
         Net::SMTPAuthenticationError,
         Net::SMTPFatalError,
         Net::SMTPSyntaxError,
         Net::SMTPServerBusy,
         IOError,
         SocketError,
         Errno::ECONNREFUSED => error
    Rails.logger.warn("[User#welcome_send] Welcome email delivery skipped: #{error.class} - #{error.message}")
  end

  def avatar_name
    AVATAR_OPTIONS.fetch(avatar_key.presence || "avatar_marine")[:name]
  end

  def avatar_asset
    AVATAR_OPTIONS.fetch(avatar_key.presence || "avatar_marine")[:asset]
  end

  # --------------------
  # XP & LEVEL
  # --------------------
  def add_xp(amount)
    xp_gain = amount.to_f.round
    return false if xp_gain <= 0

    previous_level = current_level
    self.xp_total = xp_total.to_i + xp_gain
    self.xp = xp.to_i + xp_gain

    while !max_level? && xp.to_i >= xp_needed_for_current_level
      level_up!
    end

    self.xp = 0 if max_level?
    save!(validate: false)
    BadgeAwarder.call(self, context: :level_up) if level.to_i > previous_level
    level.to_i > previous_level
  end

  def xp_progress_percentage
    return 100 if max_level?
    return 0 if xp_needed_for_current_level.zero?

    [((xp.to_i.to_f / xp_needed_for_current_level) * 100).round, 100].min
  end

  def next_level_xp
    xp_needed_for_current_level
  end

  def xp_needed_for_current_level
    return 0 if max_level?

    GamifiedXp.xp_needed_for_level(current_level)
  end

  def level_up!
    return if max_level?

    xp_cost = xp_needed_for_current_level
    self.xp = xp.to_i - xp_cost
    self.level = current_level + 1
    self.xp = 0 if max_level?
  end

  def recalc_level_from_total_xp
    self.xp_total = [xp_total.to_i, 0].max
    self.level = GamifiedXp.level_from_total_xp(xp_total)
    self.xp = GamifiedXp.xp_within_level(xp_total)
    self.xp = 0 if max_level?
    self
  end

  def max_level?
    current_level >= GamifiedXp::MAX_LEVEL
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

    BadgeAwarder.call(self, context: :login)
  end

  private

  def current_level
    level.to_i.nonzero? || 1
  end

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
