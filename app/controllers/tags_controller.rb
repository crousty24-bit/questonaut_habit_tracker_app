class TagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_habit
  before_action :set_tag, only: %i[update destroy]

  def index
    @tags = @habit.tags.order(:title)
  end

  def create
    @tag = @habit.tags.new(tag_params)

    if @tag.save
      redirect_to habit_tags_path(@habit), notice: "Tag was successfully created."
    else
      @tags = @habit.tags.order(:title)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @tag.update(tag_params)
      redirect_to habit_tags_path(@habit), notice: "Tag was successfully updated.", status: :see_other
    else
      @tags = @habit.tags.order(:title)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @tag.destroy!
    redirect_to habit_tags_path(@habit), notice: "Tag was successfully destroyed.", status: :see_other
  end

  private

  def set_habit
    @habit = current_user.habits.find(params[:habit_id])
  end

  def set_tag
    @tag = @habit.tags.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:title)
  end
end
