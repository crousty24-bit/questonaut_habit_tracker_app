# --------------------
# BADGES HABIT / USER
# --------------------
{
  "Welcome" => "habit/welcome.png",
  "First Mission" => "habit/firstmission.png",
  "Daily Login" => "habit/dailylogin.png", 
  "Veteran" => "habit/veteran.png"
}.each do |name, file|
  badge = Badge.find_or_create_by!(name: name)
  badge.icon.attach(
    io: File.open(Rails.root.join("app/assets/images/asset_badge/#{file}")),
    filename: File.basename(file)
  ) unless badge.icon.attached?
end

# --------------------
# STREAK BADGES
# --------------------
{
  "Streak 3" => "streak/3days.png",
  "Streak 7" => "streak/7days.png",
  "Streak 10" => "streak/10days.png",
  "Streak 15" => "streak/15days.png",
  "Streak 30" => "streak/30days.png",
  "Streak 45" => "streak/45days.png",
  "Streak 60" => "streak/60days.png",
  "Streak 90" => "streak/90days.png"
}.each do |name, file|
  badge = Badge.find_or_create_by!(name: name)
  badge.icon.attach(
    io: File.open(Rails.root.join("app/assets/images/asset_badge/#{file}")),
    filename: File.basename(file)
  ) unless badge.icon.attached?
end

# --------------------
# LEVEL BADGES
# --------------------
{
  "Level 1" => "level/lvl1.png",
  "Level 3" => "level/lvl3.png",
  "Level 10" => "level/lvl10.png",
  "Level 15" => "level/lvl15.png",
  "Level 30" => "level/lvl30.png",
  "Level 45" => "level/lvl45.png",
  "Level 50" => "level/lvl50.png",
  "Level 100" => "level/lvl100.png",
  "Level 150" => "level/lvl150.png",
  "Level 200" => "level/lvl200.png",
  "Level 250" => "level/level250.png"
}.each do |name, file|
  badge = Badge.find_or_create_by!(name: name)
  badge.icon.attach(
    io: File.open(Rails.root.join("app/assets/images/asset_badge/#{file}")),
    filename: File.basename(file)
  ) unless badge.icon.attached?
end

# --------------------
# TAG BADGES
# --------------------
{
  "Tag: Fitness" => "tags/fitness.png",
  "Tag: Learning" => "tags/learning.png",
  "Tag: Nutrition" => "tags/nutrition.png",
  "Tag: Productivity" => "tags/productivity.png",
  "Tag: Health" => "tags/health.png"
}.each do |name, file|
  badge = Badge.find_or_create_by!(name: name)
  badge.icon.attach(
    io: File.open(Rails.root.join("app/assets/images/asset_badge/#{file}")),
    filename: File.basename(file)
  ) unless badge.icon.attached?
end

# --------------------
# TEST USERS
# --------------------
[
  { name: "Test User 1", email: "testuser1@questonaut.test" },
  { name: "Test User 2", email: "testuser2@questonaut.test" },
  { name: "Test User 3", email: "testuser3@questonaut.test" },
  { name: "Test User 4", email: "testuser4@questonaut.test" },
  { name: "Test User 5", email: "testuser5@questonaut.test" }
].each do |attributes|
  user = User.find_or_initialize_by(email: attributes[:email])
  user.name = attributes[:name]
  user.password = "password123" if user.new_record?
  user.password_confirmation = "password123" if user.new_record?
  user.save!
end
