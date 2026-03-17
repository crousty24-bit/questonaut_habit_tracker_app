require "test_helper"

class HabitLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @habit_log = habit_logs(:one)
  end

  test "should get index" do
    get habit_logs_url
    assert_response :success
  end

  test "should get new" do
    get new_habit_log_url
    assert_response :success
  end

  test "should create habit_log" do
    assert_difference("HabitLog.count") do
      post habit_logs_url, params: { habit_log: { completed: @habit_log.completed, date: @habit_log.date, habit_id: @habit_log.habit_id } }
    end

    assert_redirected_to habit_log_url(HabitLog.last)
  end

  test "should show habit_log" do
    get habit_log_url(@habit_log)
    assert_response :success
  end

  test "should get edit" do
    get edit_habit_log_url(@habit_log)
    assert_response :success
  end

  test "should update habit_log" do
    patch habit_log_url(@habit_log), params: { habit_log: { completed: @habit_log.completed, date: @habit_log.date, habit_id: @habit_log.habit_id } }
    assert_redirected_to habit_log_url(@habit_log)
  end

  test "should destroy habit_log" do
    assert_difference("HabitLog.count", -1) do
      delete habit_log_url(@habit_log)
    end

    assert_redirected_to habit_logs_url
  end
end
