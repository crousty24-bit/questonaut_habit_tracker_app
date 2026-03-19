class ApplicationController < ActionController::Base
  before_action :award_login_badges
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def award_login_badges
    return unless user_signed_in?
    current_user.award_daily_login
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
