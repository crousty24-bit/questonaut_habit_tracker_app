module DashboardState
  extend ActiveSupport::Concern

  COCKPIT_BADGES_LIMIT = 10

  private

  def load_dashboard_state
    @today = Date.current
    @now = Time.current
    @new_habit = dashboard_new_habit
    @new_habit.category_name ||= "health"
    @current_category = selected_category
    @deleting_habit = habit_pending_deletion
    @show_delete_habit_modal = @deleting_habit.present?

    if defined?(@editing_habit) && @editing_habit.present?
      @editing_habit.category_name ||= @editing_habit.primary_category
    end

    all_habits = current_user.habits.includes(:tags, :habit_logs).order(created_at: :desc)
    @dashboard_habits = all_habits
    @streak_reset_habits = all_habits.select { |habit| habit.streak_reset_alert?(as_of: @today) }
    @habits = all_habits
    @habits = @habits.select { |habit| habit.primary_category == @current_category } if @current_category.present?
    @recent_badges = current_user.user_badges
                                 .includes(:badge)
                                 .order(created_at: :desc)
                                 .limit(3)
                                 .map(&:badge)
    @weekly_completed_logs = HabitLog.joins(:habit)
                                     .where(habits: { user_id: current_user.id }, validated_on: 6.days.ago..@today)
    load_cockpit_state(all_habits, visible_habits: @habits)
  end

  def render_dashboard_update(status: :ok)
    load_dashboard_state

    render turbo_stream: [
      turbo_stream.replace("navbar", partial: "shared/navbar"),
      turbo_stream.update("dashboard_content", partial: "pages/dashboard_content")
    ], status: status
  end

  def selected_category
    category = params[:category].to_s.downcase
    return if category.blank? || category == "all"
    return category if Habit::CATEGORIES.include?(category)
  end

  def habit_pending_deletion
    habit_id = params[:delete_mission_id].presence
    return unless habit_id

    current_user.habits.find_by(id: habit_id)
  end

  def dashboard_new_habit
    candidate = defined?(@habit) ? @habit : nil
    return candidate if candidate.is_a?(Habit) && candidate.new_record?

    current_user.habits.new
  end

  def load_cockpit_state(all_habits, visible_habits: all_habits)
    @dashboard_login_streak = current_user.login_streak.to_i
    @dashboard_best_streak = all_habits.map { |habit| habit.current_streak(as_of: @today) }.max || 0
    @dashboard_completed_today = all_habits.count { |habit| habit.completed_on?(@today) }
    @dashboard_weekly_completed = @weekly_completed_logs.count
    @dashboard_weekly_completion_rate = if all_habits.any?
      [(@dashboard_weekly_completed.to_f / (all_habits.count * 7) * 100).round, 100].min
    else
      0
    end
    @dashboard_core_temperature = [[18 + (all_habits.count - @dashboard_completed_today) * 16, 96].min, 14].max
    @dashboard_oxygen_reserve = if all_habits.any?
      [[(@dashboard_completed_today.to_f / all_habits.count * 100).round, 100].min, 22].max
    else
      22
    end
    @cockpit_featured_quests = build_cockpit_featured_quests(visible_habits)
    @cockpit_badges = build_cockpit_badges(all_habits)
    @cockpit_badges_total_count = Badge.count
    @cockpit_unlocked_badges_count = current_user.badges.count
  end

  def build_cockpit_featured_quests(habits)
    habits.map do |habit|
      {
        habit: habit,
        title: habit.title,
        type: cockpit_mission_type(habit),
        xp_reward: GamifiedXp.xp_gain_for(level: current_user.level, streak: habit.projected_streak(as_of: @today)),
        progress_value: cockpit_habit_progress(habit),
        accent: cockpit_habit_accent(habit.primary_category)
      }
    end
  end

  def build_cockpit_badges(habits)
    user_badge_ids = current_user.badge_ids

    Badge.all.sort_by(&:collection_sort_key).first(COCKPIT_BADGES_LIMIT).map do |badge|
      unlocked = user_badge_ids.include?(badge.id)

      {
        badge: badge,
        unlocked: unlocked,
        name: cockpit_badge_name(badge),
        subtitle: unlocked ? cockpit_badge_subtitle(badge) : nil,
        color: cockpit_badge_color(badge),
        progress_percent: unlocked ? 100 : cockpit_badge_progress(badge, habits)
      }
    end
  end

  def cockpit_mission_type(habit)
    case habit.primary_category
    when "productivity" then "Mission Principale"
    when "learning" then "Exploration"
    else "Maintenance"
    end
  end

  def cockpit_habit_progress(habit)
    return 100 if habit.completed_on?(@today)

    value = if habit.frequency == "daily"
      [habit.success_rate, 18].max
    else
      weekly_count = habit.habit_logs.count { |log| log.validated_on.between?(6.days.ago.to_date, @today) }
      [(weekly_count / 7.0 * 100).round, 14].max
    end

    [value, 100].min
  end

  def cockpit_habit_accent(category)
    case category
    when "health" then "#ff4757"
    when "productivity" then "#00f3ff"
    when "learning" then "#bc13fe"
    when "fitness" then "#ff6b35"
    when "nutrition" then "#4ade80"
    else "#00f3ff"
    end
  end

  def cockpit_badge_name(badge)
    return badge.name.delete_prefix("Tag: ").strip if badge.collection_group == :category

    badge.display_name
  end

  def cockpit_badge_subtitle(badge)
    subtitle = badge.collection_subtitle
    return if subtitle.blank? || subtitle == cockpit_badge_name(badge)

    subtitle
  end

  def cockpit_badge_color(badge)
    case badge.collection_group
    when :streak then "orange"
    when :level then "cyan"
    when :category then "green"
    else "violet"
    end
  end

  def cockpit_badge_progress(badge, habits)
    case badge.collection_group
    when :streak
      target = badge.name[/\d+/].to_i
      target.positive? ? [(@dashboard_best_streak.to_f / target * 100).round, 100].min : 0
    when :level
      target = badge.name[/\d+/].to_i
      target.positive? ? [((current_user.level.to_i.nonzero? || 1).to_f / target * 100).round, 100].min : 0
    when :category
      category = badge.name.delete_prefix("Tag: ").strip.downcase
      category_streak = habits.select { |habit| habit.primary_category == category }
                              .map { |habit| habit.current_streak(as_of: @today) }
                              .max.to_i
      [((category_streak.to_f / 30) * 100).round, 100].min
    else
      cockpit_mission_badge_progress(badge, habits)
    end
  end

  def cockpit_mission_badge_progress(badge, habits)
    case badge.name
    when "Welcome"
      @dashboard_login_streak.positive? ? 100 : 0
    when "First Mission"
      habits.any? ? 100 : 0
    when "Daily Login"
      [(@dashboard_login_streak.to_f / 30 * 100).round, 100].min
    when "Veteran"
      created_at = current_user.created_at&.to_date
      return 0 unless created_at

      months_active = ((@today - created_at).to_i / 30.0)
      [(months_active / 6 * 100).round, 100].min
    else
      0
    end
  end
end
