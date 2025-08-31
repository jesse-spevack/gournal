require "test_helper"

class HabitEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)

    # Create test habit and habit entry
    @habit = Habit.create!(
      user: @user,
      name: "Test Habit",
      year: 2025,
      month: 9,
      position: 1,
      check_type: :x_marks
    )

    @habit_entry = HabitEntry.create!(
      habit: @habit,
      day: 1,
      completed: false
    )

    # Set environment variable for test
    ENV["DEMO_USER_EMAIL"] = @user.email_address
  end

  test "index renders successfully with habits" do
    get habit_entries_path

    assert_response :success
    assert_select "h1", text: /September 2025/
    assert_select ".day-row", minimum: 1
    assert_select ".checkbox-form", minimum: 1
  end
end
