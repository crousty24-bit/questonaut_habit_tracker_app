class BadgeAwarder
  def self.call(user, context: nil, habit: nil)
    new(user, context, habit).call
  end

  def initialize(user, context, habit)
    @user = user
    @context = context
    @habit = habit
  end

  def call
    award_signup_badge if @context == :user_created
    award_first_habit_badge if @context == :habit_created
    award_first_log_badge if @context == :habit_logged

    award_streak_badges if @context == :habit_logged
    award_tag_badges if @context == :habit_logged

    award_level_badges if @context == :habit_logged
    award_loyalty_badges if @context == :login
  end

  private

  # --------------------
  # GENERIC
  # --------------------

  def award(name)
    badge = Badge.find_by(name: name)
    return unless badge

    @user.user_badges.find_or_create_by(badge: badge)
  end

  # --------------------
  # USER BADGES
  # --------------------

  def award_signup_badge
    award("Welcome")
  end

  def award_first_habit_badge
    award("First Habit") if @user.habits.count == 1
  end

  def award_first_log_badge
    award("First Check") if user_logs.count == 1
  end

  def user_logs
    HabitLog.joins(:habit).where(habits: { user_id: @user.id })
  end

  # --------------------
  # STREAK (PAR HABIT ✅)
  # --------------------

  STREAKS = [3, 7, 10, 15, 30, 45, 60, 90, 120]

  def award_streak_badges
    return unless @habit

    streak = habit_streak(@habit)

    STREAKS.each do |days|
      award("Streak #{days}") if streak >= days
    end
  end

  def habit_streak(habit)
    logs = habit.habit_logs.order(date: :desc)

    return 0 if logs.empty?

    streak = 1

    logs.each_cons(2) do |a, b|
      if a.date == b.date + 1.day
        streak += 1
      else
        break
      end
    end

    streak
  end

  # --------------------
  # TAG BADGES
  # --------------------

  def award_tag_badges
    return unless @habit

    @habit.tags.each do |tag|
      award("Tag: #{tag.name}")
    end
  end

  # --------------------
  # LEVEL BADGES
  # --------------------

  LEVELS = [1, 5, 10, 15, 20, 25, 30, 50, 100, 150, 200]

  def award_level_badges
    level = user_level

    LEVELS.each do |lvl|
      award("Level #{lvl}") if level >= lvl
    end
  end

  def user_level
    (user_logs.count / 10) + 1
  end

  # --------------------
  # LOYALTY BADGES
  # --------------------

  def award_loyalty_badges
    days = (Date.today - @user.created_at.to_date).to_i

    award("1 Month") if days >= 30
    award("3 Months") if days >= 90
    award("1 Year") if days >= 365
  end
end