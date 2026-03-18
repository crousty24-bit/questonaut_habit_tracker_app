class HabitsController < ApplicationController
  before_action :set_habit, only: %i[show edit update destroy]

  def index
    @habits = current_user.habits
  end

  def show; end

  def new
    @habit = current_user.habits.new
  end

  def edit; end

  def create
    @habit = current_user.habits.new(habit_params)
    if @habit.save
      # --- GAMIFICATION ---
      current_user.add_xp(20)
      BadgeAwarder.call(current_user, context: :habit_created, habit: @habit)
      # -------------------
      redirect_to @habit, notice: "Habit was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @habit.update(habit_params)
      redirect_to @habit, notice: "Habit was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @habit.destroy!
    redirect_to habits_path, notice: "Habit was successfully destroyed.", status: :see_other
  end

  private

  def set_habit
    @habit = current_user.habits.find(params[:id])
  end

  def habit_params
    params.require(:habit).permit(:title, :description)
  end
end