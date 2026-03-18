class UserBadgesController < ApplicationController
  before_action :set_user_badge, only: %i[show edit update destroy]

  def index
    @user_badges = UserBadge.all
  end

  def show; end

  def new
    @user_badge = UserBadge.new
  end

  def edit; end

  def create
    @user_badge = UserBadge.new(user_badge_params)
    if @user_badge.save
      redirect_to @user_badge, notice: "User badge was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user_badge.update(user_badge_params)
      redirect_to @user_badge, notice: "User badge was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user_badge.destroy!
    redirect_to user_badges_path, notice: "User badge was successfully destroyed.", status: :see_other
  end

  private

  def set_user_badge
    @user_badge = UserBadge.find(params[:id])
  end

  def user_badge_params
    params.require(:user_badge).permit(:user_id, :badge_id)
  end
end