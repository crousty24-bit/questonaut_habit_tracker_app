module TestDataHelpers
  DEFAULT_PASSWORD = "password123".freeze

  def create_user(name: "Test Commander", email: "commander@example.com", password: DEFAULT_PASSWORD, **attributes)
    User.create!(
      {
        name: name,
        email: email,
        password: password,
        password_confirmation: password,
        total_xp: 0,
        level: 1
      }.merge(attributes)
    )
  end

  def create_habit(user:, title: "Morning Run", description: "Run 5 km", category_name: "health", frequency: "daily")
    Habit.create!(
      user: user.reload,
      title: title,
      description: description,
      frequency: frequency,
      category_name: category_name
    )
  end
end
