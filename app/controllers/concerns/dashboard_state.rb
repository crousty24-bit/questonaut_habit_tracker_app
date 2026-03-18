module DashboardState
  extend ActiveSupport::Concern

  private

  def load_dashboard_state
    @today = Date.current
    @habit ||= current_user.habits.new
    @habit.category_name ||= "health"

    if defined?(@editing_habit) && @editing_habit.present?
      @editing_habit.category_name ||= @editing_habit.primary_category
    end

    @habits = current_user.habits.includes(:tags, :habit_logs).order(created_at: :desc)
    @recent_badges = current_user.user_badges
                                 .includes(badge: { icon_attachment: :blob })
                                 .order(created_at: :desc)
                                 .limit(3)
                                 .map(&:badge)
    @weekly_completed_logs = HabitLog.joins(:habit)
                                     .where(habits: { user_id: current_user.id }, date: 6.days.ago..@today, completed: true)
  end

  def render_dashboard_update(status: :ok)
    load_dashboard_state

    render turbo_stream: [
      turbo_stream.replace("navbar", partial: "shared/navbar"),
      turbo_stream.update("dashboard_content", partial: "pages/dashboard_content")
    ], status: status
  end
end
