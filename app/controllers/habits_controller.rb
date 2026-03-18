class HabitsController < ApplicationController
  before_action :set_habit, only: %i[show edit update destroy]

  def index
    load_habits_state
  end

  def show; end

  def new
    @habit = current_user.habits.new
  end

  def edit; end

  def create
    redirect_target = params[:return_to] == habits_path ? habits_path : dashboard_path
    @habit = current_user.habits.new(habit_params)
    if @habit.save
      # --- GAMIFICATION ---
      current_user.add_xp(20)
      BadgeAwarder.call(current_user, context: :habit_created, habit: @habit)
      # -------------------
      redirect_to redirect_target
    else
      @show_create_habit_modal = true
      if redirect_target == habits_path
        load_habits_state
        render :index, status: :unprocessable_entity
      else
        load_dashboard_state
        render "pages/dashboard", status: :unprocessable_entity
      end
    end
  end

  def update
    if @habit.update(habit_params)
      redirect_back fallback_location: habits_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @habit.destroy!
    redirect_back fallback_location: habits_path
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
    @recent_badges = current_user.user_badges
                                 .includes(badge: { icon_attachment: :blob })
                                 .order(created_at: :desc)
                                 .limit(3)
                                 .map(&:badge)
    @weekly_completed_logs = HabitLog.joins(:habit)
                                     .where(habits: { user_id: current_user.id }, date: 6.days.ago..@today, completed: true)
  end

  def load_habits_state
    @today = Date.current
    @habits = current_user.habits.includes(:tags, :habit_logs).order(created_at: :desc)
    @habit ||= current_user.habits.new
    @habit.category_name ||= "health"
  end
end
