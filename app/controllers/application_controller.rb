class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :award_login_badges

  def award_login_badges
    return unless user_signed_in?

    BadgeAwarder.call(current_user, context: :login)
  end
end
