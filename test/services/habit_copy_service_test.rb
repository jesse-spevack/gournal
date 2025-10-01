require "test_helper"

class HabitCopyServiceTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "should respond to class method call" do
    assert_respond_to HabitCopyService, :call
  end

  test "class method call should delegate to instance" do
    # Ensure the class method returns the same result as instance method
    Habit.create!(name: "Test", user: @user, month: 7, year: 2024, position: 1, check_type: "x_marks")

    # Using class method
    class_method_result = HabitCopyService.call(user: @user, target_year: 2024, target_month: 8)

    # Verify it returns an array with the copied habit
    assert_kind_of Array, class_method_result
    assert_equal 1, class_method_result.length
    assert_equal "Test", class_method_result.first.name
  end

  test "should copy habits from previous month" do
    # Create habits for July 2024
    Habit.create!(name: "Exercise", user: @user, month: 7, year: 2024, position: 1, check_type: "x_marks")
    Habit.create!(name: "Read", user: @user, month: 7, year: 2024, position: 2, check_type: "blots")

    # Create habit for different user (should not be copied)
    Habit.create!(name: "Meditate", user: users(:two), month: 7, year: 2024, position: 1, check_type: "x_marks")

    # Use service to copy to August 2024
    copied_habits = HabitCopyService.call(user: @user, target_year: 2024, target_month: 8)

    assert_equal 2, copied_habits.length

    # Check first copied habit
    copied_habit1 = copied_habits.find { |h| h.name == "Exercise" }
    assert_not_nil copied_habit1
    assert_equal "Exercise", copied_habit1.name
    assert_equal @user, copied_habit1.user
    assert_equal 8, copied_habit1.month
    assert_equal 2024, copied_habit1.year
    assert_equal 1, copied_habit1.position
    assert_equal "x_marks", copied_habit1.check_type
    assert copied_habit1.active

    # Check second copied habit
    copied_habit2 = copied_habits.find { |h| h.name == "Read" }
    assert_not_nil copied_habit2
    assert_equal "Read", copied_habit2.name
    assert_equal @user, copied_habit2.user
    assert_equal 8, copied_habit2.month
    assert_equal 2024, copied_habit2.year
    assert_equal 2, copied_habit2.position
    assert_equal "blots", copied_habit2.check_type
    assert copied_habit2.active

    # Verify habits from different user were not copied
    refute copied_habits.any? { |h| h.name == "Meditate" }
  end

  test "should handle December to January transition" do
    # Create habit for December 2024
    Habit.create!(name: "Exercise", user: @user, month: 12, year: 2024, position: 1, check_type: "x_marks")

    # Use service to copy to January 2025
    copied_habits = HabitCopyService.call(user: @user, target_year: 2025, target_month: 1)

    assert_equal 1, copied_habits.length
    copied_habit = copied_habits.first
    assert_equal "Exercise", copied_habit.name
    assert_equal @user, copied_habit.user
    assert_equal 1, copied_habit.month
    assert_equal 2025, copied_habit.year
    assert_equal 1, copied_habit.position
    assert_equal "x_marks", copied_habit.check_type
  end

  test "should handle January to previous year December lookup" do
    # Create habit for December 2023
    Habit.create!(name: "Exercise", user: @user, month: 12, year: 2023, position: 1, check_type: "blots")

    # Use service to copy to January 2024 (should look back to December 2023)
    copied_habits = HabitCopyService.call(user: @user, target_year: 2024, target_month: 1)

    assert_equal 1, copied_habits.length
    copied_habit = copied_habits.first
    assert_equal "Exercise", copied_habit.name
    assert_equal @user, copied_habit.user
    assert_equal 1, copied_habit.month
    assert_equal 2024, copied_habit.year
    assert_equal "blots", copied_habit.check_type
  end

  test "should return empty array when no previous habits exist" do
    # No habits exist for previous month
    copied_habits = HabitCopyService.call(user: @user, target_year: 2024, target_month: 8)

    assert_equal [], copied_habits
    assert_kind_of Array, copied_habits
  end

  test "should preserve all attributes including check_type" do
    # Create habit with specific attributes
    Habit.create!(
      name: "Complex Habit",
      user: @user,
      month: 7,
      year: 2024,
      position: 5,
      active: false,
      check_type: "blots"
    )

    # Use service to copy to August
    copied_habits = HabitCopyService.call(user: @user, target_year: 2024, target_month: 8)
    copied_habit = copied_habits.first

    assert_equal "Complex Habit", copied_habit.name
    assert_equal @user, copied_habit.user
    assert_equal 8, copied_habit.month
    assert_equal 2024, copied_habit.year
    assert_equal 5, copied_habit.position
    refute copied_habit.active
    assert_equal "blots", copied_habit.check_type
  end

  test "should preserve check_type from original habits" do
    # Create habits for July 2024 with specific check types
    Habit.create!(name: "Exercise", user: @user, month: 7, year: 2024, position: 1, check_type: "x_marks")
    Habit.create!(name: "Read", user: @user, month: 7, year: 2024, position: 2, check_type: "blots")

    # Use service to copy to August 2024
    copied_habits = HabitCopyService.call(user: @user, target_year: 2024, target_month: 8)

    # Should preserve the check types from originals
    exercise_copy = copied_habits.find { |h| h.name == "Exercise" }
    read_copy = copied_habits.find { |h| h.name == "Read" }

    assert_equal "x_marks", exercise_copy.check_type
    assert_equal "blots", read_copy.check_type
  end

  # Tests for habit entry creation
  test "creates habit entries for all days in target month" do
    Habit.create!(name: "Exercise", user: @user, month: 7, year: 2024, position: 1, check_type: "x_marks")

    copied_habits = HabitCopyService.call(user: @user, target_year: 2024, target_month: 8)
    copied_habit = copied_habits.first

    # August has 31 days
    assert_equal 31, copied_habit.habit_entries.count
  end

  test "creates habit entries with all days represented" do
    Habit.create!(name: "Exercise", user: @user, month: 7, year: 2024, position: 1, check_type: "x_marks")

    copied_habits = HabitCopyService.call(user: @user, target_year: 2024, target_month: 8)
    copied_habit = copied_habits.first

    days = copied_habit.habit_entries.map(&:day).sort
    assert_equal (1..31).to_a, days
  end

  test "creates habit entries with proper random styles" do
    Habit.create!(name: "Exercise", user: @user, month: 7, year: 2024, position: 1, check_type: "x_marks")

    copied_habits = HabitCopyService.call(user: @user, target_year: 2024, target_month: 8)
    copied_habit = copied_habits.first

    entries = copied_habit.habit_entries
    assert entries.all? { |e| e.checkbox_style.present? }
    assert entries.all? { |e| e.check_style.present? }
  end

  test "creates habit entries with check_style matching habit check_type for x_marks" do
    Habit.create!(name: "Exercise", user: @user, month: 7, year: 2024, position: 1, check_type: "x_marks")

    copied_habits = HabitCopyService.call(user: @user, target_year: 2024, target_month: 8)
    copied_habit = copied_habits.first

    entries = copied_habit.habit_entries
    assert entries.all? { |e| e.check_style.start_with?("x_style_") }
  end

  test "creates habit entries with check_style matching habit check_type for blots" do
    Habit.create!(name: "Meditation", user: @user, month: 7, year: 2024, position: 1, check_type: "blots")

    copied_habits = HabitCopyService.call(user: @user, target_year: 2024, target_month: 8)
    copied_habit = copied_habits.first

    entries = copied_habit.habit_entries
    assert entries.all? { |e| e.check_style.start_with?("blot_style_") }
  end

  test "December to January transition creates correct number of entries" do
    Habit.create!(name: "Exercise", user: @user, month: 12, year: 2024, position: 1, check_type: "x_marks")

    copied_habits = HabitCopyService.call(user: @user, target_year: 2025, target_month: 1)
    copied_habit = copied_habits.first

    # January has 31 days
    assert_equal 31, copied_habit.habit_entries.count
  end

  test "creates entries for February with 28 days" do
    Habit.create!(name: "Exercise", user: @user, month: 1, year: 2025, position: 1, check_type: "x_marks")

    copied_habits = HabitCopyService.call(user: @user, target_year: 2025, target_month: 2)
    copied_habit = copied_habits.first

    # February 2025 has 28 days
    assert_equal 28, copied_habit.habit_entries.count
  end

  test "all created entries default to completed false" do
    Habit.create!(name: "Exercise", user: @user, month: 7, year: 2024, position: 1, check_type: "x_marks")

    copied_habits = HabitCopyService.call(user: @user, target_year: 2024, target_month: 8)
    copied_habit = copied_habits.first

    entries = copied_habit.habit_entries
    assert entries.all? { |e| e.completed == false }
  end
end
