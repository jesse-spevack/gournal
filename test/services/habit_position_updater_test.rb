require "test_helper"

class HabitPositionUpdaterTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @current_date = Date.new(2024, 1, 1)
    @habit1 = create_habit("Habit 1", position: 1)
    @habit2 = create_habit("Habit 2", position: 2)
    @habit3 = create_habit("Habit 3", position: 3)
    @habit4 = create_habit("Habit 4", position: 4)
  end

  test "moves habit from position 1 to position 3" do
    result = HabitPositionUpdater.call(habit: @habit1, new_position: 3)

    assert result

    @habit1.reload
    @habit2.reload
    @habit3.reload
    @habit4.reload

    assert_equal 1, @habit2.position
    assert_equal 2, @habit3.position
    assert_equal 3, @habit1.position
    assert_equal 4, @habit4.position
  end

  test "moves habit from position 3 to position 1" do
    result = HabitPositionUpdater.call(habit: @habit3, new_position: 1)

    assert result

    @habit1.reload
    @habit2.reload
    @habit3.reload
    @habit4.reload

    assert_equal 1, @habit3.position
    assert_equal 2, @habit1.position
    assert_equal 3, @habit2.position
    assert_equal 4, @habit4.position
  end

  test "moves habit to last position" do
    result = HabitPositionUpdater.call(habit: @habit2, new_position: 4)

    assert result

    @habit1.reload
    @habit2.reload
    @habit3.reload
    @habit4.reload

    assert_equal 1, @habit1.position
    assert_equal 2, @habit3.position
    assert_equal 3, @habit4.position
    assert_equal 4, @habit2.position
  end

  test "handles moving to same position" do
    result = HabitPositionUpdater.call(habit: @habit2, new_position: 2)

    assert result

    @habit1.reload
    @habit2.reload
    @habit3.reload
    @habit4.reload

    assert_equal 1, @habit1.position
    assert_equal 2, @habit2.position
    assert_equal 3, @habit3.position
    assert_equal 4, @habit4.position
  end

  test "handles position beyond current range" do
    result = HabitPositionUpdater.call(habit: @habit1, new_position: 10)

    assert result

    @habit1.reload
    @habit2.reload
    @habit3.reload
    @habit4.reload

    assert_equal 1, @habit2.position
    assert_equal 2, @habit3.position
    assert_equal 3, @habit4.position
    assert_equal 10, @habit1.position
  end

  test "only affects habits for same user, year, and month" do
    different_user = users(:two)
    different_habit = create_habit_for_user(different_user, "Different User Habit", position: 1)

    result = HabitPositionUpdater.call(habit: @habit1, new_position: 3)

    assert result
    different_habit.reload
    assert_equal 1, different_habit.position
  end

  test "only affects active habits" do
    inactive_habit = create_habit("Inactive Habit", position: 5, active: false)

    result = HabitPositionUpdater.call(habit: @habit1, new_position: 3)

    assert result
    inactive_habit.reload
    assert_equal 5, inactive_habit.position
  end

  private

  def create_habit(name, position:, active: true)
    @user.habits.create!(
      name: name,
      year: @current_date.year,
      month: @current_date.month,
      position: position,
      check_type: :x_marks,
      active: active
    )
  end

  def create_habit_for_user(user, name, position:, active: true)
    user.habits.create!(
      name: name,
      year: @current_date.year,
      month: @current_date.month,
      position: position,
      check_type: :x_marks,
      active: active
    )
  end
end
