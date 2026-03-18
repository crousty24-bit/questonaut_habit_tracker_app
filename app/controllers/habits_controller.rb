class HabitsController < ApplicationController
  before_action :set_habit, only: %i[show edit update destroy]

  def create
    @habit = current_user.habits.new(habit_params)
    if @habit.save
      # --- GAMIFICATION ---
      current_user.add_xp(20)
      BadgeAwarder.call(current_user, context: :habit_created, habit: @habit)
      # -------------------
      redirect_to dashboard_path
    else
      @show_create_habit_modal = true
      load_dashboard_state
      render "pages/dashboard", status: :unprocessable_entity
    end
  end

  def update
    if @habit.update(habit_params)
      redirect_to dashboard_path
    else
      @editing_habit = @habit
      @show_edit_habit_modal = true
      load_dashboard_state
      render "pages/dashboard", status: :unprocessable_entity
    end
  end

  def destroy
    @habit.destroy!
    redirect_to dashboard_path
  end

  private

  def set_habit
    @habit = current_user.habits.find(params[:id])
  end

  def habit_params
    params.require(:habit).permit(:title, :description, :frequency, :category_name)
  end

  def load_dashboard_state
    @today = Date.current
    @habits = current_user.habits.includes(:tags, :habit_logs).order(created_at: :desc)
    @habit ||= current_user.habits.new
    @habit.category_name ||= "health"
    if defined?(@editing_habit) && @editing_habit.present?
      @editing_habit.category_name ||= @editing_habit.primary_category
    end
    @recent_badges = current_user.user_badges
                                 .includes(badge: { icon_attachment: :blob })
                                 .order(created_at: :desc)
                                 .limit(3)
                                 .map(&:badge)
    @weekly_completed_logs = HabitLog.joins(:habit)
                                     .where(habits: { user_id: current_user.id }, date: 6.days.ago..@today, completed: true)
  end
end
