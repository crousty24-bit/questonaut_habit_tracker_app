class HabitsController < ApplicationController
  include DashboardState

  before_action :set_habit, only: %i[show edit update destroy]

  def create
    @habit = current_user.habits.new(habit_params)
    respond_to do |format|
      if @habit.save
        current_user.add_xp(20)
        BadgeAwarder.call(current_user, context: :habit_created, habit: @habit)

        format.turbo_stream { render_dashboard_update }
        format.html { redirect_to dashboard_path }
      else
        @show_create_habit_modal = true

        format.turbo_stream { render_dashboard_update(status: :unprocessable_entity) }
        format.html do
          load_dashboard_state
          render "pages/dashboard", status: :unprocessable_entity
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @habit.update(habit_params)
        format.turbo_stream { render_dashboard_update }
        format.html { redirect_to dashboard_path }
      else
        @editing_habit = @habit
        @show_edit_habit_modal = true

        format.turbo_stream { render_dashboard_update(status: :unprocessable_entity) }
        format.html do
          load_dashboard_state
          render "pages/dashboard", status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @habit.destroy!

    respond_to do |format|
      format.turbo_stream { render_dashboard_update }
      format.html { redirect_to dashboard_path }
    end
  end

  private

  def set_habit
    @habit = current_user.habits.find(params[:id])
  end

  def habit_params
    params.require(:habit).permit(:title, :description, :frequency, :category_name)
  end
end
