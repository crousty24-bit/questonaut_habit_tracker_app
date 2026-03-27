class HabitLogsController < ApplicationController
  include DashboardState

  before_action :authenticate_user!
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
    log_date = parsed_log_date
    completed_value = ActiveModel::Type::Boolean.new.cast(habit_log_params[:completed])

    @habit_log = @habit.habit_logs.find_or_initialize_by(date: log_date)
    already_completed = @habit_log.persisted? && @habit_log.completed?
    @habit_log.completed = completed_value

    respond_to do |format|
      if log_date && @habit_log.save
        if @habit_log.completed? && !already_completed
          current_user.add_xp(10) unless @habit_log.previously_new_record?
          BadgeAwarder.call(current_user, context: :habit_logged, habit: @habit, awarded_on: @habit_log.date)
        end

        format.turbo_stream { render_dashboard_update }
        format.html do
          redirect_to dashboard_path,
                      notice: (@habit_log.completed? && !already_completed ? "Mission successfully validated." : "Mission was already validated for today.")
        end
      else
        @habit_log ||= @habit.habit_logs.build(completed: completed_value)
        @habit_log.errors.add(:date, "is invalid") unless log_date

        format.turbo_stream { render_dashboard_update(status: :unprocessable_entity) }
        format.html do
          load_dashboard_state
          render "pages/dashboard", status: :unprocessable_entity
        end
      end
    end
  end

  def update
    if @habit_log.update(habit_log_params)
      redirect_to dashboard_path, notice: "Habit log was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @habit_log.destroy!
    redirect_to dashboard_path, notice: "Habit log was successfully destroyed.", status: :see_other
  end

  private

  def set_habit_log
    @habit_log = HabitLog.joins(:habit).where(habits: { user_id: current_user.id }).find(params[:id])
  end

  def habit_log_params
    params.require(:habit_log).permit(:date, :completed, :habit_id)
  end

  def parsed_log_date
    raw_date = habit_log_params[:date]
    return Date.current if raw_date.blank?

    Date.iso8601(raw_date.to_s)
  rescue ArgumentError
    nil
  end
end
