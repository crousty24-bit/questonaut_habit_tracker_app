class UserBadgesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_badge, only: :destroy

  def create
    @user_badge = current_user.user_badges.new(user_badge_params)

    if @user_badge.save
      redirect_to statistics_path, notice: "Badge was successfully added.", status: :see_other
    else
      redirect_to statistics_path, alert: @user_badge.errors.full_messages.to_sentence, status: :see_other
    end
  end

  def destroy
    @user_badge.destroy!
    redirect_to statistics_path, notice: "Badge was successfully removed.", status: :see_other
  end

  private

  def set_user_badge
    @user_badge = current_user.user_badges.find(params[:id])
  end

  def user_badge_params
    params.require(:user_badge).permit(:badge_id)
  end
end
