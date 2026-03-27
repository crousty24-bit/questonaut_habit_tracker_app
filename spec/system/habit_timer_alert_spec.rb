require "rails_helper"

RSpec.describe "Habit timer and missed streak alerts" do
  it "shows a daily mission inside the cockpit quest logs" do
    travel_to(Time.zone.parse("2026-03-19 10:15:00")) do
      user = create_user(email: "timer@example.com")
      create_habit(user: user, title: "Morning Yoga")

      sign_in_via_ui(user)
      visit dashboard_path

      within(".cockpit-widget--terminal") do
        expect(page).to have_text("Quest Logs")
        expect(page).to have_text("Morning Yoga")
        expect(page).to have_button("VALIDER")
      end
    end
  end

  it "shows a weekly mission inside the cockpit quest logs" do
    travel_to(Time.zone.parse("2026-03-19 10:15:00")) do
      user = create_user(email: "weekly-timer@example.com")
      create_habit(user: user, title: "Weekly Review", frequency: "weekly")

      sign_in_via_ui(user)
      visit dashboard_path

      within(".cockpit-widget--terminal") do
        expect(page).to have_text("Weekly Review")
        expect(page).to have_text("Maintenance")
      end
    end
  end

  it "keeps the completed state visible after a mission is validated" do
    travel_to(Time.zone.parse("2026-03-19 10:15:00")) do
      user = create_user(email: "timer-completed@example.com")
      habit = create_habit(user: user, title: "Read 20 pages")
      HabitLog.create!(habit: habit, date: Date.new(2026, 3, 19), completed: true)

      sign_in_via_ui(user)
      visit dashboard_path

      within(".cockpit-quest-card", text: "Read 20 pages") do
        expect(page).to have_button("COMPLÉTÉE", disabled: true)
      end
    end
  end

  it "alerts the user and resets the visible streak after a missed day" do
    travel_to(Time.zone.parse("2026-03-20 09:00:00")) do
      user = create_user(email: "alert-reset@example.com")
      habit = create_habit(user: user, title: "Daily Run")
      HabitLog.create!(habit: habit, date: Date.new(2026, 3, 16), completed: true)
      HabitLog.create!(habit: habit, date: Date.new(2026, 3, 17), completed: true)
      HabitLog.create!(habit: habit, date: Date.new(2026, 3, 18), completed: true)

      sign_in_via_ui(user)
      visit dashboard_path

      expect(page).to have_text("1 mission missed the last 24 hours")
      expect(page).to have_text("Daily Run")
      expect(page).to have_text("reset from 3 to 0")

      within(".cockpit-quest-card", text: "Daily Run") do
        expect(page).to have_text("🔥 0 days")
      end
    end
  end
end
