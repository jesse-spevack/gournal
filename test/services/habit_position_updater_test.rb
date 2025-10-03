require "test_helper"

class HabitPositionUpdaterTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    travel_to Date.new(2024, 1, 1) do
      @habit1 = create_habit("Habit 1", position: 1)
      @habit2 = create_habit("Habit 2", position: 2)
      @habit3 = create_habit("Habit 3", position: 3)
      @habit4 = create_habit("Habit 4", position: 4)
    end
  end

  test "successfully updates positions with valid batch data" do
    positions_data = [
      { "id" => @habit1.id, "position" => 3 },
      { "id" => @habit2.id, "position" => 1 },
      { "id" => @habit3.id, "position" => 4 },
      { "id" => @habit4.id, "position" => 2 }
    ]

    travel_to Date.new(2024, 1, 1) do
      result = HabitPositionUpdater.call(user: @user, positions: positions_data)
      assert_equal({ success: true }, result)
    end

    [ @habit1, @habit2, @habit3, @habit4 ].each(&:reload)
    assert_equal 3, @habit1.position
    assert_equal 1, @habit2.position
    assert_equal 4, @habit3.position
    assert_equal 2, @habit4.position
  end

  test "handles symbol keys in positions data" do
    positions_data = [
      { id: @habit1.id, position: 2 },
      { id: @habit2.id, position: 1 }
    ]

    travel_to Date.new(2024, 1, 1) do
      result = HabitPositionUpdater.call(user: @user, positions: positions_data)
      assert_equal({ success: true }, result)
    end

    @habit1.reload
    @habit2.reload
    assert_equal 2, @habit1.position
    assert_equal 1, @habit2.position
  end

  test "ignores non-existent habit IDs" do
    positions_data = [
      { "id" => @habit1.id, "position" => 1 },
      { "id" => 99999, "position" => 2 },  # Non-existent ID
      { "id" => @habit2.id, "position" => 2 }
    ]

    travel_to Date.new(2024, 1, 1) do
      result = HabitPositionUpdater.call(user: @user, positions: positions_data)
      assert_equal({ success: true }, result)
    end

    @habit1.reload
    @habit2.reload
    assert_equal 1, @habit1.position
    assert_equal 2, @habit2.position
  end

  test "only updates current user's habits" do
    different_user = users(:two)
    travel_to Date.new(2024, 1, 1) do
      @other_habit = create_habit_for_user(different_user, "Other User Habit", position: 1)
    end

    positions_data = [
      { "id" => @habit1.id, "position" => 2 },
      { "id" => @other_habit.id, "position" => 1 }  # Different user's habit
    ]

    travel_to Date.new(2024, 1, 1) do
      result = HabitPositionUpdater.call(user: @user, positions: positions_data)
      assert_equal({ success: true }, result)
    end

    @habit1.reload
    @other_habit.reload
    assert_equal 2, @habit1.position
    assert_equal 1, @other_habit.position  # Should remain unchanged
  end

  test "only affects active habits" do
    travel_to Date.new(2024, 1, 1) do
      @inactive_habit = create_habit("Inactive Habit", position: 5, active: false)
    end

    positions_data = [
      { "id" => @habit1.id, "position" => 1 },
      { "id" => @inactive_habit.id, "position" => 2 }
    ]

    travel_to Date.new(2024, 1, 1) do
      result = HabitPositionUpdater.call(user: @user, positions: positions_data)
      assert_equal({ success: true }, result)
    end

    @habit1.reload
    @inactive_habit.reload
    assert_equal 1, @habit1.position
    assert_equal 5, @inactive_habit.position  # Should remain unchanged
  end

  test "returns error for empty positions array" do
    result = HabitPositionUpdater.call(user: @user, positions: [])
    assert_equal({ success: false, error: "Invalid positions data" }, result)
  end

  test "returns error for non-array positions" do
    result = HabitPositionUpdater.call(user: @user, positions: "invalid")
    assert_equal({ success: false, error: "Invalid positions data" }, result)
  end

  test "returns error for positions missing required fields" do
    positions_data = [
      { "id" => @habit1.id },  # Missing position
      { "position" => 1 }      # Missing id
    ]

    result = HabitPositionUpdater.call(user: @user, positions: positions_data)
    assert_equal({ success: false, error: "Invalid positions data" }, result)
  end

  test "maintains data integrity with complex reordering" do
    positions_data = [
      { "id" => @habit4.id, "position" => 1 },  # 4 -> 1
      { "id" => @habit3.id, "position" => 2 },  # 3 -> 2
      { "id" => @habit2.id, "position" => 3 },  # 2 -> 3
      { "id" => @habit1.id, "position" => 4 }   # 1 -> 4
    ]

    travel_to Date.new(2024, 1, 1) do
      result = HabitPositionUpdater.call(user: @user, positions: positions_data)
      assert_equal({ success: true }, result)
    end

    [ @habit1, @habit2, @habit3, @habit4 ].each(&:reload)

    # Verify complete reversal
    assert_equal 4, @habit1.position
    assert_equal 3, @habit2.position
    assert_equal 2, @habit3.position
    assert_equal 1, @habit4.position

    # Verify no position conflicts (all positions unique and sequential)
    positions = [ @habit1, @habit2, @habit3, @habit4 ].map(&:position).sort
    assert_equal [ 1, 2, 3, 4 ], positions
  end

  test "handles positions as integers" do
    positions_data = [
      { "id" => @habit1.id.to_s, "position" => "2" },  # String values
      { "id" => @habit2.id, "position" => 1 }          # Mixed types
    ]

    travel_to Date.new(2024, 1, 1) do
      result = HabitPositionUpdater.call(user: @user, positions: positions_data)
      assert_equal({ success: true }, result)
    end

    @habit1.reload
    @habit2.reload
    assert_equal 2, @habit1.position
    assert_equal 1, @habit2.position
  end

  test "scopes to current date month and year" do
    # Create habits in different month
    travel_to Date.new(2024, 2, 1) do
      @feb_habit = create_habit("February Habit", position: 1)
    end

    positions_data = [
      { "id" => @habit1.id, "position" => 2 },      # January habit
      { "id" => @feb_habit.id, "position" => 1 }    # February habit
    ]

    travel_to Date.new(2024, 1, 1) do  # Update in January
      result = HabitPositionUpdater.call(user: @user, positions: positions_data)
      assert_equal({ success: true }, result)
    end

    @habit1.reload
    @feb_habit.reload

    assert_equal 2, @habit1.position     # Should be updated
    assert_equal 1, @feb_habit.position  # Should remain unchanged (different month)
  end

  test "handles database errors gracefully" do
    # Test with invalid position data that would normally cause constraint errors
    # but our service should validate before attempting database operations
    positions_data = [
      { "id" => nil, "position" => 1 }  # Invalid ID will fail validation
    ]

    result = HabitPositionUpdater.call(user: @user, positions: positions_data)
    assert_equal({ success: false, error: "Invalid positions data" }, result)

    # Verify original positions unchanged
    [ @habit1, @habit2, @habit3, @habit4 ].each(&:reload)
    assert_equal 1, @habit1.position
    assert_equal 2, @habit2.position
    assert_equal 3, @habit3.position
    assert_equal 4, @habit4.position
  end

  test "accepts target year and month parameters" do
    # Create habits in February 2024
    travel_to Date.new(2024, 2, 1) do
      @feb_habit1 = create_habit("Feb Habit 1", position: 1)
      @feb_habit2 = create_habit("Feb Habit 2", position: 2)
    end

    positions_data = [
      { "id" => @feb_habit1.id, "position" => 2 },
      { "id" => @feb_habit2.id, "position" => 1 }
    ]

    # Call service with explicit year and month parameters
    travel_to Date.new(2024, 3, 1) do  # Current date is March
      result = HabitPositionUpdater.call(
        user: @user,
        positions: positions_data,
        year: 2024,
        month: 2
      )
      assert_equal({ success: true }, result)
    end

    @feb_habit1.reload
    @feb_habit2.reload
    assert_equal 2, @feb_habit1.position
    assert_equal 1, @feb_habit2.position
  end

  test "updates positions for a specific non-current month" do
    # Create habits in February 2024
    travel_to Date.new(2024, 2, 1) do
      @feb_habit1 = create_habit("Feb Habit 1", position: 1)
      @feb_habit2 = create_habit("Feb Habit 2", position: 2)
      @feb_habit3 = create_habit("Feb Habit 3", position: 3)
    end

    positions_data = [
      { "id" => @feb_habit1.id, "position" => 3 },
      { "id" => @feb_habit2.id, "position" => 1 },
      { "id" => @feb_habit3.id, "position" => 2 }
    ]

    # Update February habits while current date is January
    travel_to Date.new(2024, 1, 15) do
      result = HabitPositionUpdater.call(
        user: @user,
        positions: positions_data,
        year: 2024,
        month: 2
      )
      assert_equal({ success: true }, result)
    end

    @feb_habit1.reload
    @feb_habit2.reload
    @feb_habit3.reload
    assert_equal 3, @feb_habit1.position
    assert_equal 1, @feb_habit2.position
    assert_equal 2, @feb_habit3.position
  end

  test "only affects habits from target month, not current month" do
    # Create habits in February 2024 (setup already created January habits)
    travel_to Date.new(2024, 2, 1) do
      @feb_habit1 = create_habit("Feb Habit 1", position: 1)
      @feb_habit2 = create_habit("Feb Habit 2", position: 2)
    end

    # Try to update February habits while in January
    positions_data = [
      { "id" => @feb_habit1.id, "position" => 2 },
      { "id" => @feb_habit2.id, "position" => 1 }
    ]

    travel_to Date.new(2024, 1, 15) do  # Current month is January
      result = HabitPositionUpdater.call(
        user: @user,
        positions: positions_data,
        year: 2024,
        month: 2  # Target month is February
      )
      assert_equal({ success: true }, result)
    end

    # February habits should be updated
    @feb_habit1.reload
    @feb_habit2.reload
    assert_equal 2, @feb_habit1.position
    assert_equal 1, @feb_habit2.position

    # January habits (from setup) should remain unchanged
    @habit1.reload
    @habit2.reload
    assert_equal 1, @habit1.position
    assert_equal 2, @habit2.position
  end

  private

  def create_habit(name, position:, active: true)
    current_date = Date.current
    @user.habits.create!(
      name: name,
      year: current_date.year,
      month: current_date.month,
      position: position,
      check_type: :x_marks,
      active: active
    )
  end

  def create_habit_for_user(user, name, position:, active: true)
    current_date = Date.current
    user.habits.create!(
      name: name,
      year: current_date.year,
      month: current_date.month,
      position: position,
      check_type: :x_marks,
      active: active
    )
  end
end
