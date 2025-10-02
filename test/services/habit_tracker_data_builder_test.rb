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

  # Auto-heal tests
  test "auto-heal creates missing entries when habits exist without entries" do
    habit_without_entries = Habit.create!(
      user: @user,
      name: "Habit Without Entries",
      year: 2025,
      month: 11,
      position: 1,
      check_type: :x_marks,
      active: true
    )
    habit_without_entries.habit_entries.destroy_all

    assert_equal 0, habit_without_entries.habit_entries.count

    result = HabitTrackerDataBuilder.call(user: @user, year: 2025, month: 11)

    habit_without_entries.reload
    assert_equal 30, habit_without_entries.habit_entries.count
    assert result.habit_entry_for(habit_without_entries.id, 1).present?
  end

  test "auto-heal does not create duplicate entries if some already exist" do
    habit_partial = Habit.create!(
      user: @user,
      name: "Habit With Partial Entries",
      year: 2025,
      month: 11,
      position: 2,
      check_type: :x_marks,
      active: true
    )
    habit_partial.habit_entries.destroy_all

    # Create entries for days 1-5 only
    (1..5).each do |day|
      HabitEntry.create!(habit: habit_partial, day: day, completed: false)
    end

    assert_equal 5, habit_partial.habit_entries.count

    result = HabitTrackerDataBuilder.call(user: @user, year: 2025, month: 11)

    habit_partial.reload
    assert_equal 30, habit_partial.habit_entries.count

    # Verify no duplicates
    days = habit_partial.habit_entries.map(&:day)
    assert_equal days.uniq, days
  end


  test "auto-heal handles multiple habits missing entries efficiently" do
    habits = []
    3.times do |i|
      habit = Habit.create!(
        user: @user,
        name: "Habit #{i}",
        year: 2025,
        month: 12,
        position: i + 1,
        check_type: :x_marks,
        active: true
      )
      habit.habit_entries.destroy_all
      habits << habit
    end

    HabitTrackerDataBuilder.call(user: @user, year: 2025, month: 12)

    habits.each do |habit|
      habit.reload
      assert_equal 31, habit.habit_entries.count
    end
  end
end
