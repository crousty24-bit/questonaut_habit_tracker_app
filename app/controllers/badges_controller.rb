class BadgesController < ApplicationController
  before_action :authenticate_user!, only: %i[index show collection]
  before_action :set_badge, only: %i[show edit update destroy]

  def index
    @habits = current_user.habits.includes(:tags, :habit_logs).order(created_at: :desc)
    @completed_logs = HabitLog.joins(:habit).where(habits: { user_id: current_user.id }, completed: true)

    @success_rate = success_rate
    @mission_days = @completed_logs.select(:date).distinct.count
    @best_streak = @habits.map { |habit| streak_for(habit) }.max || 0
    @unlocked_badges_count = current_user.badges.count
    @total_badges_count = Badge.count
    @category_distribution = category_distribution
    @detailed_habits = @habits.sort_by { |habit| [-habit_success_rate(habit), -streak_for(habit)] }.first(4)
  end

  def collection
    @badges = Badge.includes(icon_attachment: :blob).order(:name)
    @user_badge_ids = current_user.badge_ids
    @unlocked_badges_count = current_user.badges.count
    @badge_groups = {
      "Streak Achievements" => @badges.select { |badge| badge.name.start_with?("Streak ") },
      "Mission Milestones" => @badges.select { |badge| mission_badge?(badge) },
      "Level Ranks" => @badges.select { |badge| badge.name.start_with?("Level ") },
      "Category Collection" => @badges.select { |badge| badge.name.start_with?("Tag: ") }
    }

    render partial: "badge_collection"
  end

  def show; end

  def new
    @badge = Badge.new
  end

  def edit; end

  def create
    @badge = Badge.new(badge_params)
    if @badge.save
      redirect_to @badge, notice: "Badge was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @badge.update(badge_params)
      redirect_to @badge, notice: "Badge was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @badge.destroy!
    redirect_to badges_path, notice: "Badge was successfully destroyed.", status: :see_other
  end

  private

  def set_badge
    @badge = Badge.find(params[:id])
  end

  def badge_params
    params.require(:badge).permit(:name, :description, :icon)
  end

  def success_rate
    total_logs = HabitLog.joins(:habit).where(habits: { user_id: current_user.id }).count
    return 0 if total_logs.zero?

    ((@completed_logs.count.to_f / total_logs) * 100).round
  end

  def streak_for(habit)
    dates = habit.habit_logs.select(&:completed?).map(&:date).compact.sort.reverse
    return 0 if dates.empty?

    streak = 1
    dates.each_cons(2) do |current_date, previous_date|
      break unless current_date == previous_date + 1.day
      streak += 1
    end
    streak
  end

  def habit_success_rate(habit)
    total_logs = habit.habit_logs.count
    return 0 if total_logs.zero?

    ((habit.habit_logs.count(&:completed?) / total_logs.to_f) * 100).round
  end

  def category_distribution
    counts = Hash.new(0)
    @habits.each do |habit|
      counts[habit.primary_category] += 1
    end
    counts.sort_by { |_, value| -value }.to_h
  end

  def mission_badge?(badge)
    !(badge.name.start_with?("Streak ") || badge.name.start_with?("Level ") || badge.name.start_with?("Tag: "))
  end
end
