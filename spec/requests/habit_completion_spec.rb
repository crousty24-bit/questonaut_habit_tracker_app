require "rails_helper"

RSpec.describe "Habit completion" do
  it "allows an authenticated user to validate a mission" do
    user = create_user(email: "validator@example.com")
    habit = create_habit(user: user, title: "Meditate")

    login_as(user)
    follow_redirect!

    expect do
      post habit_habit_logs_path(habit), habit_log: {
        date: Date.current,
        completed: true,
        habit_id: habit.id
      }
    end.to change(HabitLog, :count).by(1)

    log = habit.habit_logs.order(:created_at).last

    expect(last_response.status).to eq(302)
    expect(log.completed).to be(true)
    expect(log.date).to eq(Date.current)
  end

  it "awards xp when an authenticated user validates a mission" do
    user = create_user(email: "xp@example.com")
    habit = create_habit(user: user, title: "Practice guitar")

    login_as(user)
    follow_redirect!

    post habit_habit_logs_path(habit), habit_log: {
      date: Date.current,
      completed: true,
      habit_id: habit.id
    }

    expect(last_response.status).to eq(302)
    expect(user.reload.total_xp).to eq(10)
    expect(user.level).to eq(1)
  end

  it "prevents a mission from granting completion rewards twice on the same day" do
    user = create_user(email: "once-a-day@example.com")
    habit = create_habit(user: user, title: "Drink water")

    login_as(user)
    follow_redirect!

    post habit_habit_logs_path(habit), habit_log: {
      date: Date.current,
      completed: true,
      habit_id: habit.id
    }

    expect(user.reload.total_xp).to eq(10)
    expect(habit.habit_logs.count).to eq(1)

    post habit_habit_logs_path(habit), habit_log: {
      date: Date.current,
      completed: true,
      habit_id: habit.id
    }

    expect(last_response.status).to eq(302)
    expect(last_response["Location"]).to include("/dashboard")
    expect(user.reload.total_xp).to eq(10)
    expect(habit.habit_logs.count).to eq(1)
  end
end
