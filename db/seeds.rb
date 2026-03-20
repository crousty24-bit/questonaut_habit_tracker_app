# --------------------
# BADGES HABIT / USER
# --------------------
{
  "Welcome" => "habit/welcomeV2.png",
  "First Mission" => "habit/firstmissionV2.png",
  "Daily Login" => "habit/dailylogin.png",
  "Veteran" => "habit/veteran.png"
}.each do |name, file|
  badge = Badge.find_or_create_by!(name: name)
  badge.update!(image_key: File.basename(file))
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
  badge.update!(image_key: File.basename(file))
end

# --------------------
# LEVEL BADGES
# --------------------
Badge::LEVEL_IMAGE_KEYS.each do |level, image_key|
  badge = Badge.find_or_create_by!(name: "Level #{level}")
  badge.update!(image_key: image_key, description: "Level #{level}")
end

legacy_level_five_badge = Badge.find_by(name: "Level 3")
level_five_badge = Badge.find_by(name: "Level 5")

if legacy_level_five_badge && level_five_badge && legacy_level_five_badge.id != level_five_badge.id
  legacy_level_five_badge.user_badges.find_each do |user_badge|
    duplicate = UserBadge.exists?(user_id: user_badge.user_id, badge_id: level_five_badge.id)

    if duplicate
      user_badge.destroy!
    else
      user_badge.update!(badge: level_five_badge)
    end
  end

  legacy_level_five_badge.destroy!
end

Badge.where(name: "Level 45").delete_all

# --------------------
# TAG BADGES
# --------------------
{
  "Tag: Fitness" => { file: "tags/fitness.png", description: "Fitness" },
  "Tag: Learning" => { file: "tags/learning.png", description: "Learning" },
  "Tag: Nutrition" => { file: "tags/nutrition.png", description: "Nutrition" },
  "Tag: Productivity" => { file: "tags/productivity.png", description: "Productivity" },
  "Tag: Health" => { file: "tags/health.png", description: "Health" }
}.each do |name, config|
  file = config[:file]
  badge = Badge.find_or_create_by!(name: name)
  badge.update!(image_key: File.basename(file), description: config[:description])
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
