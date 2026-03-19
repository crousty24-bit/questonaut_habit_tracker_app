require "rails_helper"

RSpec.describe "Access control" do
  it "redirects a visitor away from the dashboard" do
    get dashboard_path

    expect(last_response.status).to eq(302)
    expect(last_response["Location"]).to include("/users/sign_in")
  end

  it "redirects a visitor away from statistics" do
    get statistics_path

    expect(last_response.status).to eq(302)
    expect(last_response["Location"]).to include("/users/sign_in")
  end

  it "allows an authenticated user to access the dashboard and statistics" do
    user = create_user(email: "secured@example.com")

    login_as(user)
    follow_redirect!

    get dashboard_path
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Welcome Back, Commander")

    get statistics_path
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Mission Report")
  end

  it "renders category filter hooks on the dashboard for mission sorting" do
    user = create_user(email: "filters@example.com")
    create_habit(user: user, title: "Meal Prep", category_name: "nutrition")
    create_habit(user: user, title: "Study Ruby", category_name: "learning")

    login_as(user)
    follow_redirect!

    get dashboard_path

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('data-dashboard-filter="nutrition"')
    expect(last_response.body).to include('data-dashboard-filter="learning"')
    expect(last_response.body).to include('data-category="nutrition"')
    expect(last_response.body).to include('data-category="learning"')
  end
end
