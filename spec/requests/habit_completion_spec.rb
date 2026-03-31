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
      post habit_habit_logs_path(habit), params: {
        habit_log: {
          validated_on: Date.current,
          completed: true,
          habit_id: habit.id
        }
      }
    end.to change(HabitLog, :count).by(1)

    log = habit.habit_logs.order(:created_at).last

    expect(response).to have_http_status(:found)
    expect(log.validated_on).to eq(Date.current)
    expect(log.streak_days).to eq(1)
  end

  it "awards XP using the user's level and the current streak" do
    xp_total = GamifiedXp.xp_threshold_for_level(3) + 25
    user = create_user(email: "xp@example.com", level: 3, xp_total: xp_total, xp: 25)
    habit = create_habit(user: user, title: "Practice guitar")
    create(:habit_log, habit: habit, validated_on: Date.current - 1.day)

    login_as(user)
    follow_redirect!

    post habit_habit_logs_path(habit), params: {
      habit_log: {
        validated_on: Date.current,
        completed: true,
        habit_id: habit.id
      }
    }

    expected_xp = GamifiedXp.xp_gain_for(level: 3, streak: 2)

    expect(response).to have_http_status(:found)
    expect(user.reload.xp_total).to eq(xp_total + expected_xp)
    expect(user.level).to eq(3)
  end

  it "prevents a mission from granting completion rewards twice on the same day" do
    user = create_user(email: "once-a-day@example.com")
    habit = create_habit(user: user, title: "Drink water")

    login_as(user)
    follow_redirect!

    post habit_habit_logs_path(habit), params: {
      habit_log: {
        validated_on: Date.current,
        completed: true,
        habit_id: habit.id
      }
    }

    expect(user.reload.xp_total).to eq(GamifiedXp.xp_gain_for(level: 1, streak: 1))
    expect(habit.habit_logs.count).to eq(1)

    post habit_habit_logs_path(habit), params: {
      habit_log: {
        validated_on: Date.current,
        completed: true,
        habit_id: habit.id
      }
    }

    expect(response).to have_http_status(:found)
    expect(response.headers["Location"]).to include("/dashboard")
    expect(user.reload.xp_total).to eq(GamifiedXp.xp_gain_for(level: 1, streak: 1))
    expect(habit.habit_logs.count).to eq(1)
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
        HabitLog.create!(habit: habit, validated_on: Date.new(2026, 3, 1) + offset, streak_days: 0)
      end
      habit.recalculate_streaks!

      login_as(user)
      follow_redirect!

      post habit_habit_logs_path(habit), params: {
        habit_log: {
          validated_on: Date.new(2026, 3, 30),
          completed: true,
          habit_id: habit.id
        }
      }

      expect(response).to have_http_status(:found)
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

  it "returns an unprocessable response instead of crashing when the completion date is invalid" do
    user = create_user(email: "invalid-date@example.com")
    habit = create_habit(user: user, title: "Stretch")

    login_as(user)
    follow_redirect!

    expect do
      post habit_habit_logs_path(habit), params: {
        habit_log: {
          validated_on: "not-a-date",
          completed: true,
          habit_id: habit.id
        }
      }
    end.not_to change(HabitLog, :count)

    expect(response).to have_http_status(:unprocessable_content)
  end

  it "redirects habit log update and destroy actions back to the dashboard" do
    user = create_user(email: "log-redirects@example.com")
    habit = create_habit(user: user, title: "Journal")
    habit_log = HabitLog.create!(habit: habit, validated_on: Date.current, streak_days: 1)

    login_as(user)
    follow_redirect!

    patch habit_habit_log_path(habit, habit_log), params: {
      habit_log: {
        validated_on: Date.current + 1.day,
        streak_days: 1
      }
    }

    expect(response).to have_http_status(:see_other)
    expect(response.headers["Location"]).to end_with(dashboard_path)

    delete habit_habit_log_path(habit, habit_log)

    expect(response).to have_http_status(:see_other)
    expect(response.headers["Location"]).to end_with(dashboard_path)
  end
end
