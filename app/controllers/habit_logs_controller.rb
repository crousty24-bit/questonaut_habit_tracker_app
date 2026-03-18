class HabitLogsController < ApplicationController
  before_action :set_habit_log, only: %i[show edit update destroy]

  def index
    @habit_logs = HabitLog.all
  end

  def show; end

  def new
    @habit_log = HabitLog.new
  end

  def edit; end

  def create
    @habit_log = HabitLog.new(habit_log_params)
    if @habit_log.save
      # --- GAMIFICATION ---
      current_user.add_xp(10)
      BadgeAwarder.call(current_user, context: :habit_logged, habit: @habit_log.habit)
      # -------------------
      redirect_to @habit_log, notice: "Habit log was successfully created."
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
    @habit_log = HabitLog.find(params[:id])
  end

  def habit_log_params
    params.require(:habit_log).permit(:date, :completed, :habit_id)
  end
end