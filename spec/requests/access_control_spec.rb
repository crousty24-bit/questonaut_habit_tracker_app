require "rails_helper"

RSpec.describe "Access control" do
  before do
    allow_any_instance_of(User).to receive(:welcome_send)
  end

  it "redirects a visitor away from the dashboard" do
    get dashboard_path

    expect(response).to have_http_status(:found)
    expect(response.headers["Location"]).to include("/users/sign_in")
  end

  it "redirects a visitor away from statistics" do
    get statistics_path

    expect(response).to have_http_status(:found)
    expect(response.headers["Location"]).to include("/users/sign_in")
  end

  it "redirects a visitor away from mission creation" do
    post habits_path, params: { habit: attributes_for(:habit) }

    expect(response).to have_http_status(:found)
    expect(response.headers["Location"]).to include("/users/sign_in")
  end

  it "redirects a visitor away from mission validation" do
    habit = create(:habit)

    post habit_habit_logs_path(habit), params: { habit_log: attributes_for(:habit_log).merge(habit_id: habit.id) }

    expect(response).to have_http_status(:found)
    expect(response.headers["Location"]).to include("/users/sign_in")
  end

  it "allows an authenticated user to access the dashboard and statistics" do
    user = create(:user, email: "secured@example.com")

    login_as(user)
    follow_redirect!

    get dashboard_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Welcome Back, Commander")

    get statistics_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Mission Report")
  end

  it "redirects a successful login to the dashboard" do
    user = create(:user, email: "redirect-login@example.com")

    post user_session_path, params: { user: { email: user.email, password: TestDataHelpers::DEFAULT_PASSWORD } }

    expect(response).to have_http_status(:see_other)
    expect(response.headers["Location"]).to end_with(dashboard_path)
  end

  it "renders category filter hooks on the dashboard for mission sorting" do
    user = create(:user, email: "filters@example.com")
    create(:habit, user: user, title: "Meal Prep", category_name: "nutrition")
    create(:habit, user: user, title: "Study Ruby", category_name: "learning")

    login_as(user)
    follow_redirect!

    get dashboard_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('data-dashboard-filter="nutrition"')
    expect(response.body).to include('data-dashboard-filter="learning"')
    expect(response.body).to include('data-category="nutrition"')
    expect(response.body).to include('data-category="learning"')
  end

  it "prevents an authenticated user from updating another user's mission" do
    owner = create(:user, email: "owner@example.com")
    intruder = create(:user, email: "intruder@example.com")
    habit = create(:habit, user: owner)

    login_as(intruder)
    follow_redirect!

    patch habit_path(habit), params: {
      habit: attributes_for(
        :habit,
        title: "Hijacked Mission",
        frequency: "weekly",
        category_name: "productivity"
      )
    }

    expect(response).to have_http_status(:not_found)
  end

  it "prevents an authenticated user from validating another user's mission" do
    owner = create(:user, email: "mission-owner@example.com")
    intruder = create(:user, email: "mission-intruder@example.com")
    habit = create(:habit, user: owner)

    login_as(intruder)
    follow_redirect!

    post habit_habit_logs_path(habit), params: { habit_log: attributes_for(:habit_log).merge(habit_id: habit.id) }

    expect(response).to have_http_status(:not_found)
  end
end
