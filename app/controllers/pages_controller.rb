class PagesController < ApplicationController
  include DashboardState

  before_action :authenticate_user!, only: [:dashboard]

  def home
  end

  def dashboard
    load_dashboard_state
  end
end
