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
  end

  test "should respond to class method call" do
    assert_respond_to HabitEntryCreator, :call
  end

  test "class method call should delegate to instance" do
    # Delete any auto-created entries
    @habit.habit_entries.destroy_all

    result = HabitEntryCreator.call(habit: @habit)

    # Verify entries were created
    assert_equal 31, @habit.habit_entries.count
  end

  test "creates entries for full month with 28 days" do
    february_habit = Habit.create!(
      user: @user,
      name: "February Habit",
      year: 2025,
      month: 2,
      position: 2,
      check_type: :x_marks,
      active: true
    )
    february_habit.habit_entries.destroy_all

    HabitEntryCreator.call(habit: february_habit)

    assert_equal 28, february_habit.habit_entries.count
  end

  test "creates entries for full month with 30 days" do
    april_habit = Habit.create!(
      user: @user,
      name: "April Habit",
      year: 2025,
      month: 4,
      position: 3,
      check_type: :x_marks,
      active: true
    )
    april_habit.habit_entries.destroy_all

    HabitEntryCreator.call(habit: april_habit)

    assert_equal 30, april_habit.habit_entries.count
  end

  test "creates entries for full month with 31 days" do
    @habit.habit_entries.destroy_all

    HabitEntryCreator.call(habit: @habit)

    assert_equal 31, @habit.habit_entries.count
  end

  test "assigns random checkbox_style to each entry" do
    @habit.habit_entries.destroy_all

    HabitEntryCreator.call(habit: @habit)

    entries = @habit.habit_entries.reload
    assert entries.all? { |e| e.checkbox_style.present? }

    # Verify styles are from valid enum
    valid_styles = HabitEntry.checkbox_styles.keys
    assert entries.all? { |e| valid_styles.include?(e.checkbox_style) }
  end

  test "assigns random check_style to each entry" do
    @habit.habit_entries.destroy_all

    HabitEntryCreator.call(habit: @habit)

    entries = @habit.habit_entries.reload
    assert entries.all? { |e| e.check_style.present? }

    # Verify styles are from valid enum
    valid_styles = HabitEntry.check_styles.keys
    assert entries.all? { |e| valid_styles.include?(e.check_style) }
  end

  test "check_style matches habit.check_type for x_marks habits" do
    @habit.habit_entries.destroy_all

    HabitEntryCreator.call(habit: @habit)

    entries = @habit.habit_entries.reload
    assert entries.all? { |e| e.check_style.start_with?("x_style_") }
  end

  test "check_style matches habit.check_type for blots habits" do
    blot_habit = Habit.create!(
      user: @user,
      name: "Blot Habit",
      year: 2025,
      month: 10,
      position: 4,
      check_type: :blots,
      active: true
    )
    blot_habit.habit_entries.destroy_all

    HabitEntryCreator.call(habit: blot_habit)

    entries = blot_habit.habit_entries.reload
    assert entries.all? { |e| e.check_style.start_with?("blot_style_") }
  end

  test "all entries default to completed: false" do
    @habit.habit_entries.destroy_all

    HabitEntryCreator.call(habit: @habit)

    entries = @habit.habit_entries.reload
    assert entries.all? { |e| e.completed == false }
  end

  test "creates entries for each day of the month" do
    @habit.habit_entries.destroy_all

    HabitEntryCreator.call(habit: @habit)

    entries = @habit.habit_entries.reload
    days = entries.map(&:day).sort
    assert_equal (1..31).to_a, days
  end

  test "sets created_at and updated_at timestamps" do
    @habit.habit_entries.destroy_all

    HabitEntryCreator.call(habit: @habit)

    entries = @habit.habit_entries.reload
    assert entries.all? { |e| e.created_at.present? }
    assert entries.all? { |e| e.updated_at.present? }
  end
end
