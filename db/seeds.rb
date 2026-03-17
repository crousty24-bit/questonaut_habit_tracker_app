# Nettoyage
UserBadge.destroy_all
Badge.destroy_all
HabitLog.destroy_all
Tag.destroy_all
Difficulty.destroy_all
Habit.destroy_all
User.destroy_all

puts "Creating users..."

users = []

5.times do |i|
  users << User.create!(
    email: "user#{i+1}@mail.com",
    password: "password",
    password_confirmation: "password",
    name: "User #{i+1}",
    total_xp: rand(0..500),
    level: rand(1..5)
  )
end

puts "Creating badges..."

badges = [
  Badge.create!(name: "First Habit", description: "Complete your first habit", icon: "first.png"),
  Badge.create!(name: "3 Day Streak", description: "Complete a habit 3 days in a row", icon: "streak3.png"),
  Badge.create!(name: "10 Habits Done", description: "Complete 10 habits", icon: "10habits.png")
]

puts "Creating habits for each user..."

users.each do |user|
  rand(2..4).times do
    habit = Habit.create!(
      title: ["Run", "Read", "Meditate", "Workout", "Drink Water"].sample,
      description: "Daily self improvement habit",
      user: user
    )

    Difficulty.create!(
      title: ["Easy", "Medium", "Hard"].sample,
      habit: habit
    )

    Tag.create!(
      title: ["Health", "Mind", "Fitness", "Learning"].sample,
      habit: habit
    )

    puts "Creating habit logs..."

    7.times do |day|
      HabitLog.create!(
        habit: habit,
        date: Date.today - day,
        completed: [true, false].sample
      )
    end
  end
end

puts "Assigning badges..."

users.each do |user|
  badges.sample(2).each do |badge|
    UserBadge.create!(
      user: user,
      badge: badge
    )
  end
end

puts "Seeds created successfully!"