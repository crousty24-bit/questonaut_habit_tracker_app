require "rails_helper"

RSpec.describe "Habit delete confirmation" do
  it "shows a confirmation modal before deleting a mission" do
    user = create_user(email: "delete-modal@example.com")
    create_habit(user: user, title: "Deep Work")

    sign_in_via_ui(user)
    visit dashboard_path

    find(".habit-action-btn.delete", match: :first).click

    expect(page).to have_css("#deleteHabitModal.active")
    expect(page).to have_css("#deleteHabitModal.active", text: "Do you want to delete this mission?")
    expect(page).to have_css("#deleteHabitModal.active", text: "Deep Work")
    expect(Habit.find_by(title: "Deep Work")).to be_present
  end

  it "lets the user cancel mission deletion" do
    user = create_user(email: "delete-cancel@example.com")
    create_habit(user: user, title: "Walk 10k steps")

    sign_in_via_ui(user)
    visit dashboard_path

    find(".habit-action-btn.delete", match: :first).click
    click_link "Cancel"

    expect(page).to have_no_css("#deleteHabitModal.active")
    expect(page).to have_text("Walk 10k steps")
    expect(Habit.find_by(title: "Walk 10k steps")).to be_present
  end

  it "deletes the mission after confirmation" do
    user = create_user(email: "delete-confirm@example.com")
    create_habit(user: user, title: "Inbox Zero")

    sign_in_via_ui(user)
    visit dashboard_path

    find(".habit-action-btn.delete", match: :first).click
    expect(page).to have_css("#deleteHabitModal.active")

    expect do
      click_button "Confirm"
    end.to change(Habit, :count).by(-1)

    expect(page).to have_no_text("Inbox Zero")
  end
end
