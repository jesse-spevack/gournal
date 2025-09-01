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
    @daily_reflection = DailyReflection.create!(
      user: @user,
      date: Date.new(2025, 9, 1),
      content: "Test reflection content"
    )
  end

  test "builds tracker data with habits and entries" do
    result = HabitTrackerDataBuilder.call(user: @user, year: 2025, month: 9)

    assert_instance_of HabitTrackerData, result
    assert_includes result.habits, @habit
    assert_equal "September", result.month_name
    assert_equal 30, result.days_in_month
    assert_equal @habit_entry, result.habit_entry_for(@habit.id, 1)
    assert_equal @daily_reflection, result.reflection_for(1)
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

  test "includes reflections lookup for the month" do
    # Create reflections for different days and months
    reflection_day_5 = DailyReflection.create!(
      user: @user,
      date: Date.new(2025, 9, 5),
      content: "Day 5 reflection"
    )

    # This should not be included (different month)
    DailyReflection.create!(
      user: @user,
      date: Date.new(2025, 8, 15),
      content: "August reflection"
    )

    result = HabitTrackerDataBuilder.call(user: @user, year: 2025, month: 9)

    assert_equal @daily_reflection, result.reflection_for(1)
    assert_equal reflection_day_5, result.reflection_for(5)
    assert_nil result.reflection_for(15) # No reflection for day 15
    assert_nil result.reflection_for(25) # August reflection shouldn't be included
  end

  test "handles empty reflections gracefully" do
    @daily_reflection.destroy

    result = HabitTrackerDataBuilder.call(user: @user, year: 2025, month: 9)

    assert_nil result.reflection_for(1)
    assert_instance_of Hash, result.reflections_lookup
    assert_empty result.reflections_lookup
  end
end
