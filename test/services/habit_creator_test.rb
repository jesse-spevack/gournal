require "test_helper"

class HabitCreatorTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "successfully creates habit with correct attributes" do
    result = HabitCreator.call(user: @user, name: "Morning Exercise")

    assert result[:success]
    habit = result[:habit]
    current_date = Date.current

    assert_equal "Morning Exercise", habit.name
    assert_equal @user.id, habit.user_id
    assert_equal current_date.year, habit.year
    assert_equal current_date.month, habit.month
    assert_equal "x_marks", habit.check_type
    assert habit.active
  end

  test "sets correct position for new habit" do
    existing_habit = @user.habits.create!(
      name: "Existing Habit",
      year: Date.current.year,
      month: Date.current.month,
      position: 5,
      check_type: :x_marks,
      active: true
    )

    result = HabitCreator.call(user: @user, name: "New Habit")

    assert result[:success]
    assert_equal 6, result[:habit].position
  end

  test "creates habit entries for all days in current month" do
    result = HabitCreator.call(user: @user, name: "Daily Reading")

    assert result[:success]
    habit = result[:habit]

    current_date = Date.current
    days_in_month = Date.new(current_date.year, current_date.month, -1).day

    assert_equal days_in_month, habit.habit_entries.count

    habit.habit_entries.each_with_index do |entry, index|
      assert_equal index + 1, entry.day
      assert_equal false, entry.completed
      assert_not_nil entry.checkbox_style
      assert_not_nil entry.check_style
    end
  end

  test "assigns x_marks check styles for x_marks check type" do
    result = HabitCreator.call(user: @user, name: "Exercise")

    assert result[:success]
    habit = result[:habit]

    habit.habit_entries.each do |entry|
      assert entry.check_style.start_with?("x_style_")
    end
  end

  test "returns error when habit creation fails" do
    result = HabitCreator.call(user: @user, name: "")

    assert_not result[:success]
    assert_includes result[:errors], "Name can't be blank"
  end

  test "does not create habit entries when habit creation fails" do
    initial_count = HabitEntry.count

    HabitCreator.call(user: @user, name: "")

    assert_equal initial_count, HabitEntry.count
  end

  test "handles first habit creation when no existing habits" do
    @user.habits.destroy_all

    result = HabitCreator.call(user: @user, name: "First Habit")

    assert result[:success]
    assert_equal 1, result[:habit].position
  end
end
