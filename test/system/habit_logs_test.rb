require "application_system_test_case"

class HabitLogsTest < ApplicationSystemTestCase
  setup do
    @habit_log = habit_logs(:one)
  end

  test "visiting the index" do
    visit habit_logs_url
    assert_selector "h1", text: "Habit logs"
  end

  test "should create habit log" do
    visit habit_logs_url
    click_on "New habit log"

    check "Completed" if @habit_log.completed
    fill_in "Date", with: @habit_log.date
    fill_in "Habit", with: @habit_log.habit_id
    click_on "Create Habit log"

    assert_text "Habit log was successfully created"
    click_on "Back"
  end

  test "should update Habit log" do
    visit habit_log_url(@habit_log)
    click_on "Edit this habit log", match: :first

    check "Completed" if @habit_log.completed
    fill_in "Date", with: @habit_log.date
    fill_in "Habit", with: @habit_log.habit_id
    click_on "Update Habit log"

    assert_text "Habit log was successfully updated"
    click_on "Back"
  end

  test "should destroy Habit log" do
    visit habit_log_url(@habit_log)
    click_on "Destroy this habit log", match: :first

    assert_text "Habit log was successfully destroyed"
  end
end
