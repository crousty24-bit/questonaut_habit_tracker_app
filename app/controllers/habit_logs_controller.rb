class HabitLogsController < ApplicationController
  before_action :set_habit_log, only: %i[show edit update destroy]

  def index
    @habit_logs = HabitLog.joins(:habit).where(habits: { user_id: current_user.id })
  end

  def show; end

  def new
    @habit_log = HabitLog.new
  end

  def edit; end

  def create
    @habit = current_user.habits.find(params[:habit_id])
    log_date = habit_log_params[:date].presence || Date.current
    completed_value = ActiveModel::Type::Boolean.new.cast(habit_log_params[:completed])

    @habit_log = @habit.habit_logs.find_or_initialize_by(date: log_date)
    already_completed = @habit_log.persisted? && @habit_log.completed?
    @habit_log.completed = completed_value

    if @habit_log.save
      if @habit_log.completed? && !already_completed
        current_user.add_xp(10) unless @habit_log.previously_new_record?
        BadgeAwarder.call(current_user, context: :habit_logged, habit: @habit)
        redirect_to dashboard_path, notice: "Mission successfully validated."
      else
        redirect_to dashboard_path, notice: "Mission was already validated for today."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @habit_log.update(habit_log_params)
      redirect_to @habit_log, notice: "Habit log was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @habit_log.destroy!
    redirect_to habit_logs_path, notice: "Habit log was successfully destroyed.", status: :see_other
  end

  private

  def set_habit_log
    @habit_log = HabitLog.joins(:habit).where(habits: { user_id: current_user.id }).find(params[:id])
  end

  def habit_log_params
    params.require(:habit_log).permit(:date, :completed, :habit_id)
  end
end
