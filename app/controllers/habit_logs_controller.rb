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

    respond_to do |format|
      if log_date && completed_value
        result = HabitCompletionService.complete(@habit, current_user, validated_on: log_date)
        @habit_log = result[:habit_log]

        format.turbo_stream { render_dashboard_update }
        format.html do
          redirect_to dashboard_path,
                      notice: completion_notice(result, log_date)
        end
      else
        @habit_log = @habit.habit_logs.build(validated_on: log_date || Date.current, streak_days: 0)
        @habit_log.errors.add(:validated_on, "is invalid") unless log_date
        @habit_log.errors.add(:base, "Mission must be validated to record progress.") unless completed_value

        format.turbo_stream { render_dashboard_update(status: :unprocessable_entity) }
        format.html do
          load_dashboard_state
          render "pages/dashboard", status: :unprocessable_entity
        end
      end
    end
  end

  def update
    if @habit_log.update(updatable_habit_log_params)
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
    params.require(:habit_log).permit(:date, :validated_on, :completed, :streak_days, :habit_id)
  end

  def parsed_log_date
    raw_date = habit_log_params[:validated_on].presence || habit_log_params[:date]
    return Date.current if raw_date.blank?

    Date.iso8601(raw_date.to_s)
  rescue ArgumentError
    nil
  end

  def updatable_habit_log_params
    attributes = habit_log_params.slice(:streak_days).to_h
    validated_on = parsed_log_date
    attributes[:validated_on] = validated_on if validated_on
    attributes
  end

  def completion_notice(result, log_date)
    return "Mission was already validated for #{log_date}." if result[:already_completed]

    message = "Mission successfully validated. +#{result[:xp_gain]} XP."
    return message unless result[:leveled_up]

    "#{message} Level #{result[:new_level]} reached."
  end
end
