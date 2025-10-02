require "test_helper"

class HabitEntryCreatorTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @habit = Habit.create!(
      user: @user,
      name: "Test Habit",
      year: 2025,
      month: 10,
      position: 1,
      check_type: :x_marks,
      active: true
    )
    @habit.habit_entries.destroy_all
  end

  test "creates entries for different month lengths" do
    february_habit = Habit.create!(user: @user, name: "Feb", year: 2025, month: 2, position: 2, check_type: :x_marks, active: true)
    april_habit = Habit.create!(user: @user, name: "Apr", year: 2025, month: 4, position: 3, check_type: :x_marks, active: true)

    february_habit.habit_entries.destroy_all
    april_habit.habit_entries.destroy_all

    HabitEntryCreator.call(habit: february_habit)
    HabitEntryCreator.call(habit: april_habit)
    HabitEntryCreator.call(habit: @habit)

    assert_equal 28, february_habit.habit_entries.count
    assert_equal 30, april_habit.habit_entries.count
    assert_equal 31, @habit.habit_entries.count
  end

  test "assigns valid random styles to all entries" do
    HabitEntryCreator.call(habit: @habit)

    entries = @habit.habit_entries
    assert entries.all? { |e| HabitEntry.checkbox_styles.keys.include?(e.checkbox_style) }
    assert entries.all? { |e| e.check_style.start_with?("x_style_") }
  end

  test "assigns check styles matching habit check type" do
    blot_habit = Habit.create!(user: @user, name: "Blot", year: 2025, month: 10, position: 4, check_type: :blots, active: true)
    blot_habit.habit_entries.destroy_all

    HabitEntryCreator.call(habit: blot_habit)

    assert blot_habit.habit_entries.all? { |e| e.check_style.start_with?("blot_style_") }
  end

  test "all entries default to completed false" do
    HabitEntryCreator.call(habit: @habit)

    assert @habit.habit_entries.all? { |e| e.completed == false }
  end
end
