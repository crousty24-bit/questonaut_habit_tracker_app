class BadgesController < ApplicationController
  before_action :set_badge, only: %i[show edit update destroy]

  def index
    @badges = Badge.all
  end

  def show; end

  def new
    @badge = Badge.new
  end

  def edit; end

  def create
    @badge = Badge.new(badge_params)
    if @badge.save
      redirect_to @badge, notice: "Badge was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @badge.update(badge_params)
      redirect_to @badge, notice: "Badge was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @badge.destroy!
    redirect_to badges_path, notice: "Badge was successfully destroyed.", status: :see_other
  end

  private

  def set_badge
    @badge = Badge.find(params[:id])
  end

  def badge_params
    params.require(:badge).permit(:name, :description, :icon)
  end
end