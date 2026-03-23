# app/services/badge_awarder.rb
class BadgeAwarder
  def self.call(user, context: nil, habit: nil, awarded_on: nil)
    new(user, context, habit, awarded_on).call
  end

  def initialize(user, context, habit, awarded_on)
    @user = user
    @context = context
    @habit = habit
    @awarded_on = awarded_on&.to_date
  end

  def call
    award_first_habit_badge if @context == :habit_created

    award_streak_badges if @context == :habit_logged
    award_category_badge if @context == :habit_logged

    award_level_badges if level_award_context?
    award_login_milestone_badges if @context == :login
  end

  private

  def award(name)
    badge = Badge.find_by(name: name)
    return unless badge
    @user.user_badges.find_or_create_by(badge: badge)
  end

  def award_first_habit_badge
    award("First Mission") if @user.habits.count == 1
  end

  # --------------------
  # STREAK BADGES
  # --------------------
  STREAKS = [3, 7, 10, 15, 30, 45, 60, 90].freeze

  def award_streak_badges
    return unless @habit

    streak = habit_streak(@habit)
    STREAKS.each { |days| award("Streak #{days}") if streak >= days }
  end

  def habit_streak(habit)
    habit.current_streak(as_of: streak_reference_date)
  end

  # --------------------
  # CATEGORY BADGES
  # --------------------
  def award_category_badge
    return unless @habit
    return unless habit_streak(@habit) >= 30

    award("Tag: #{@habit.primary_category.titleize}")
  end

  # --------------------
  # LEVEL BADGES
  # --------------------
  LEVELS = [1, 5, 10, 15, 30, 50, 100, 150, 200, 250].freeze

  def award_level_badges
    level = user_level
    LEVELS.each { |lvl| award("Level #{lvl}") if level >= lvl }
  end

  def user_level
    @user.level.presence || 1
  end

  def level_award_context?
    %i[user_created habit_created habit_logged login level_up].include?(@context)
  end

  # --------------------
  # LOGIN MILESTONES
  # --------------------
  def award_login_milestone_badges
    award("Welcome") if @user.login_streak.to_i == 1
    award("Daily Login") if @user.login_streak.to_i >= 30
    award("Veteran") if @user.created_at.present? && @user.created_at.to_date <= 6.months.ago.to_date
  end

  def streak_reference_date
    @awarded_on || Date.current
  end
end
