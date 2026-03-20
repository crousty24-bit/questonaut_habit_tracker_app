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
    @badges = Badge.all
    @user_badge_ids = current_user.badge_ids
    @unlocked_badges_count = current_user.badges.count
    @badge_groups = {
      "Streak Achievements" => badges_for_collection(:streak),
      "Mission Milestones" => badges_for_collection(:mission),
      "Level Ranks" => badges_for_collection(:level),
      "Category Collection" => badges_for_collection(:category)
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
    params.require(:badge).permit(:name, :description, :image_key)
  end

  def success_rate
    total_logs = HabitLog.joins(:habit).where(habits: { user_id: current_user.id }).count
    return 0 if total_logs.zero?

    ((@completed_logs.count.to_f / total_logs) * 100).round
  end

  def streak_for(habit)
    habit.current_streak(as_of: Date.current)
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

  def badges_for_collection(group)
    @badges.select { |badge| badge.collection_group == group }
           .sort_by(&:collection_sort_key)
  end
end
