require "rails_helper"

RSpec.describe "Main feature user flow" do
  before do
    allow_any_instance_of(User).to receive(:welcome_send)
  end

  def habit_card_for(body, title)
    document = Nokogiri::HTML5.parse(body)

    document.css(".habit-card").find do |card|
      card.at_css(".dashboard-habit__title")&.text&.include?(title)
    end
  end

  it "lets a signed-in user create and validate a daily mission from the dashboard" do
    user = create(:user, email: "daily-flow@example.com")
    habit_attributes = attributes_for(
      :habit,
      title: "Morning Stretch",
      description: "Ten minutes of mobility work",
      frequency: "daily",
      category_name: "fitness"
    )

    login_as(user)
    follow_redirect!

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Welcome Back, Commander")

    expect do
      post habits_path, params: { habit: habit_attributes }
    end.to change(Habit, :count).by(1)
      .and change(Tag, :count).by(1)

    habit = user.habits.order(:created_at).last

    expect(response).to have_http_status(:found)
    expect(response.headers["Location"]).to end_with(dashboard_path)

    follow_redirect!

    created_habit_card = habit_card_for(response.body, "Morning Stretch")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Daily Missions")
    expect(created_habit_card).to be_present
    expect(created_habit_card.text).to include("Morning Stretch")
    expect(created_habit_card.text).to include("fitness")

    expect do
      post habit_habit_logs_path(habit), params: {
        habit_log: attributes_for(
          :habit_log,
          date: Date.current,
          completed: true
        ).merge(habit_id: habit.id)
      }
    end.to change(HabitLog, :count).by(1)

    expect(response).to have_http_status(:found)
    expect(response.headers["Location"]).to end_with(dashboard_path)
    expect(habit.reload.completed_on?(Date.current)).to be(true)
    expect(user.reload.total_xp).to eq(30)

    follow_redirect!

    completed_habit_card = habit_card_for(response.body, "Morning Stretch")

    expect(completed_habit_card).to be_present
    expect(completed_habit_card.text).to include("Completed")
  end

  it "lets a signed-in user create and validate a weekly mission from the dashboard" do
    user = create(:user, email: "weekly-flow@example.com")
    habit_attributes = attributes_for(
      :habit,
      title: "Weekly Review",
      description: "Review the week and plan the next one",
      frequency: "weekly",
      category_name: "productivity"
    )

    login_as(user)
    follow_redirect!

    expect do
      post habits_path, params: { habit: habit_attributes }
    end.to change(Habit, :count).by(1)
      .and change(Tag, :count).by(1)

    habit = user.habits.order(:created_at).last

    expect(response).to have_http_status(:found)
    expect(response.headers["Location"]).to end_with(dashboard_path)

    follow_redirect!

    created_habit_card = habit_card_for(response.body, "Weekly Review")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Weekly Missions")
    expect(created_habit_card).to be_present
    expect(created_habit_card.text).to include("Weekly Review")
    expect(created_habit_card.text).to include("productivity")

    expect do
      post habit_habit_logs_path(habit), params: {
        habit_log: attributes_for(
          :habit_log,
          date: Date.current,
          completed: true
        ).merge(habit_id: habit.id)
      }
    end.to change(HabitLog, :count).by(1)

    expect(response).to have_http_status(:found)
    expect(response.headers["Location"]).to end_with(dashboard_path)
    expect(habit.reload.completed_on?(Date.current)).to be(true)
    expect(user.reload.total_xp).to eq(30)

    follow_redirect!

    completed_habit_card = habit_card_for(response.body, "Weekly Review")

    expect(completed_habit_card).to be_present
    expect(completed_habit_card.text).to include("Completed")
  end
end
