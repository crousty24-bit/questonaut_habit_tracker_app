require "rails_helper"

RSpec.describe "Habit completion" do
  before do
    allow_any_instance_of(User).to receive(:welcome_send)
  end

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

  it "allows an existing incomplete log to be validated once and awards xp only once" do
    user = create_user(email: "existing-log@example.com")
    habit = create_habit(user: user, title: "Study")
    HabitLog.create!(habit: habit, date: Date.current, completed: false)

    login_as(user)
    follow_redirect!

    post habit_habit_logs_path(habit), habit_log: {
      date: Date.current,
      completed: true,
      habit_id: habit.id
    }

    expect(last_response.status).to eq(302)
    expect(habit.habit_logs.count).to eq(1)
    expect(habit.habit_logs.first.completed).to be(true)
    expect(user.reload.total_xp).to eq(10)
  end

  it "awards streak and category badges when a backfilled completion reaches a 30-day category streak" do
    [3, 7, 10, 15, 30].each do |days|
      Badge.create!(name: "Streak #{days}")
    end
    Badge.create!(name: "Tag: Fitness")

    travel_to(Date.new(2026, 4, 10)) do
      user = create_user(email: "badge-streak@example.com")
      habit = create_habit(user: user, title: "Workout", category_name: "fitness")

      29.times do |offset|
        HabitLog.create!(habit: habit, date: Date.new(2026, 3, 1) + offset, completed: true)
      end

      login_as(user)
      follow_redirect!

      post habit_habit_logs_path(habit), habit_log: {
        date: Date.new(2026, 3, 30),
        completed: true,
        habit_id: habit.id
      }

      expect(last_response.status).to eq(302)
      expect(user.reload.badges.pluck(:name)).to include(
        "Streak 3",
        "Streak 7",
        "Streak 10",
        "Streak 15",
        "Streak 30",
        "Tag: Fitness"
      )
    end
  end
end
