class CookieConsentsController < ApplicationController
  CONSENT_LEVELS = %w[essential all].freeze

  def create
    consent_level = CONSENT_LEVELS.include?(params[:level]) ? params[:level] : "essential"

    cookies[:cookie_consent] = {
      value: consent_level,
      expires: 6.months,
      same_site: :lax,
      secure: Rails.env.production?
    }

    redirect_back fallback_location: root_path, status: :see_other
  end

  def destroy
    cookies.delete(:cookie_consent, same_site: :lax, secure: Rails.env.production?)
    redirect_back fallback_location: cookies_path, status: :see_other
  end
end
