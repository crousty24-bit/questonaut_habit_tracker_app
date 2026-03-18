class ApplicationController < ActionController::Base
  before_action :award_login_badges

  private

  def award_login_badges
    return unless user_signed_in?
    current_user.award_daily_login
  end
end