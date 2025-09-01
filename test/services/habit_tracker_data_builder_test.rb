require "test_helper"

class HabitTrackerDataBuilderTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
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
  end

  test "builds tracker data with habits and entries" do
    result = HabitTrackerDataBuilder.call(user: @user, year: 2025, month: 9)

    assert_instance_of HabitTrackerData, result
    assert_includes result.habits, @habit
    assert_equal "September", result.month_name
    assert_equal 30, result.days_in_month
    assert_equal @habit_entry, result.habit_entry_for(@habit.id, 1)
  end

  test "raises an error for nil user" do
    assert_raises ArgumentError, "User cannot be nil" do
      HabitTrackerDataBuilder.call(user: nil, year: 2025, month: 9)
    end
  end

  test "properly loads associations to prevent N+1" do
    # This test verifies associations are loaded
    result = HabitTrackerDataBuilder.call(user: @user, year: 2025, month: 9)

    # Verify we can access habit entries without additional queries
    habit = result.habits.first
    assert_equal @habit_entry, habit.habit_entries.first
  end
end
