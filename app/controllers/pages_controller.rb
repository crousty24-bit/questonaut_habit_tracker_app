class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard]

  def home
  end

  def dashboard
    @today = Date.current
    @habit = current_user.habits.new
    @habit.category_name = "health"
    @habits = current_user.habits.includes(:tags, :habit_logs).order(created_at: :desc)
    @recent_badges = current_user.user_badges
                                .includes(badge: { icon_attachment: :blob })
                                .order(created_at: :desc)
                                .limit(3)
                                .map(&:badge)
    @weekly_completed_logs = HabitLog.joins(:habit)
                                    .where(habits: { user_id: current_user.id }, date: 6.days.ago..@today, completed: true)
  end
end
