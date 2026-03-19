require "rails_helper"

RSpec.describe "Habit management" do
  it "allows an authenticated user to create a new mission" do
    user = create_user(email: "creator@example.com")

    login_as(user)
    follow_redirect!

    expect do
      post habits_path, habit: {
        title: "Morning Stretch",
        description: "Ten minutes of mobility work",
        frequency: "daily",
        category_name: "fitness"
      }
    end.to change(Habit, :count).by(1)
      .and change(Tag, :count).by(1)

    created_habit = Habit.order(:created_at).last

    expect(last_response.status).to eq(302)
    expect(created_habit.title).to eq("Morning Stretch")
    expect(created_habit.primary_category).to eq("fitness")
    expect(user.reload.total_xp).to eq(20)
  end

  it "allows an authenticated user to edit a mission" do
    user = create_user(email: "editor@example.com")
    habit = create_habit(user: user, title: "Read", description: "Read 10 pages", category_name: "learning")

    login_as(user)
    follow_redirect!

    patch habit_path(habit), habit: {
      title: "Read a chapter",
      description: "Read one full chapter",
      frequency: "weekly",
      category_name: "productivity"
    }

    expect(last_response.status).to eq(302)
    expect(habit.reload.title).to eq("Read a chapter")
    expect(habit.description).to eq("Read one full chapter")
    expect(habit.frequency).to eq("weekly")
    expect(habit.primary_category).to eq("productivity")
  end

  it "allows an authenticated user to delete a mission" do
    user = create_user(email: "destroyer@example.com")
    habit = create_habit(user: user, title: "Journal")

    login_as(user)
    follow_redirect!

    expect do
      delete habit_path(habit)
    end.to change(Habit, :count).by(-1)

    expect(last_response.status).to eq(302)
    expect(user.habits.reload).to be_empty
  end
end
