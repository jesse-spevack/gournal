require "test_helper"

class HabitTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @habit_attributes = {
      name: "Exercise",
      month: 8,
      year: 2024,
      position: 1,
      user: @user,
      check_type: "x_marks"
    }
  end

  test "should belong to user" do
    habit = Habit.new(@habit_attributes)
    assert_respond_to habit, :user
    assert_equal @user, habit.user
  end

  test "should have many habit entries" do
    habit = Habit.new(@habit_attributes)
    assert_respond_to habit, :habit_entries
  end

  test "should require name" do
    habit = Habit.new(@habit_attributes.except(:name))
    refute habit.valid?
    assert_includes habit.errors[:name], "can't be blank"
  end

  test "should require month" do
    habit = Habit.new(@habit_attributes.except(:month))
    refute habit.valid?
    assert_includes habit.errors[:month], "can't be blank"
  end

  test "should require year" do
    habit = Habit.new(@habit_attributes.except(:year))
    refute habit.valid?
    assert_includes habit.errors[:year], "can't be blank"
  end

  test "should require position" do
    habit = Habit.new(@habit_attributes.except(:position))
    refute habit.valid?
    assert_includes habit.errors[:position], "can't be blank"
  end

  test "should validate month is between 1 and 12" do
    habit = Habit.new(@habit_attributes.merge(month: 0))
    refute habit.valid?
    assert_includes habit.errors[:month], "must be greater than or equal to 1"

    habit = Habit.new(@habit_attributes.merge(month: 13))
    refute habit.valid?
    assert_includes habit.errors[:month], "must be less than or equal to 12"

    habit = Habit.new(@habit_attributes.merge(month: 6))
    habit.valid? # This might fail for other reasons, but month should be valid
    refute_includes habit.errors[:month], "must be greater than or equal to 1"
    refute_includes habit.errors[:month], "must be less than or equal to 12"
  end

  test "should default active to true" do
    habit = Habit.new(@habit_attributes)
    assert habit.active
  end

  test "should allow setting active to false" do
    habit = Habit.new(@habit_attributes.merge(active: false))
    refute habit.active
  end

  test "should have unique position per user per year per month" do
    # Create first habit
    habit1 = Habit.create!(@habit_attributes)

    # Try to create second habit with same position
    habit2 = Habit.new(@habit_attributes)
    refute habit2.valid?
    assert_includes habit2.errors[:position], "has already been taken"
  end

  test "should allow same position for different users" do
    user2 = users(:two)

    # Create first habit for user one
    habit1 = Habit.create!(@habit_attributes)

    # Create second habit for user two with same position
    habit2 = Habit.new(@habit_attributes.merge(user: user2))
    assert habit2.valid?
  end

  test "should allow same position for different months" do
    # Create first habit for August
    habit1 = Habit.create!(@habit_attributes)

    # Create second habit for September with same position
    habit2 = Habit.new(@habit_attributes.merge(month: 9))
    assert habit2.valid?
  end

  test "should allow same position for different years" do
    # Create first habit for 2024
    habit1 = Habit.create!(@habit_attributes)

    # Create second habit for 2025 with same position
    habit2 = Habit.new(@habit_attributes.merge(year: 2025))
    assert habit2.valid?
  end

  test "should have current_month scope" do
    assert_respond_to Habit, :current_month

    # The scope should accept year and month parameters
    current_habits = Habit.current_month(2024, 8)
    assert_kind_of ActiveRecord::Relation, current_habits
  end

  test "current_month scope should filter by year and month" do
    # Create habits for different months
    habit_current = Habit.create!(@habit_attributes.merge(month: 8, year: 2024))
    habit_different_month = Habit.create!(@habit_attributes.merge(month: 9, year: 2024, position: 2))
    habit_different_year = Habit.create!(@habit_attributes.merge(month: 8, year: 2023, position: 3))

    current_habits = Habit.current_month(2024, 8)

    assert_includes current_habits, habit_current
    refute_includes current_habits, habit_different_month
    refute_includes current_habits, habit_different_year
  end

  test "should have copy_from_previous_month class method" do
    assert_respond_to Habit, :copy_from_previous_month
  end

  test "copy_from_previous_month should copy habits from previous month" do
    # Create habits for July 2024
    Habit.create!(name: "Exercise", user: @user, month: 7, year: 2024, position: 1, check_type: "x_marks")
    Habit.create!(name: "Read", user: @user, month: 7, year: 2024, position: 2, check_type: "blots")

    # Create habit for different user (should not be copied)
    Habit.create!(name: "Meditate", user: users(:two), month: 7, year: 2024, position: 1, check_type: "x_marks")

    # Copy to August 2024
    copied_habits = Habit.copy_from_previous_month(@user, 2024, 8)

    assert_equal 2, copied_habits.length

    # Check first copied habit
    copied_habit1 = copied_habits.find { |h| h.name == "Exercise" }
    assert_not_nil copied_habit1
    assert_equal "Exercise", copied_habit1.name
    assert_equal @user, copied_habit1.user
    assert_equal 8, copied_habit1.month
    assert_equal 2024, copied_habit1.year
    assert_equal 1, copied_habit1.position
    assert copied_habit1.active

    # Check second copied habit
    copied_habit2 = copied_habits.find { |h| h.name == "Read" }
    assert_not_nil copied_habit2
    assert_equal "Read", copied_habit2.name
    assert_equal @user, copied_habit2.user
    assert_equal 8, copied_habit2.month
    assert_equal 2024, copied_habit2.year
    assert_equal 2, copied_habit2.position
    assert copied_habit2.active

    # Verify habits from different user were not copied
    refute copied_habits.any? { |h| h.name == "Meditate" }
  end

  test "copy_from_previous_month should handle December to January transition" do
    # Create habit for December 2024
    Habit.create!(name: "Exercise", user: @user, month: 12, year: 2024, position: 1, check_type: "x_marks")

    # Copy to January 2025
    copied_habits = Habit.copy_from_previous_month(@user, 2025, 1)

    assert_equal 1, copied_habits.length
    copied_habit = copied_habits.first
    assert_equal "Exercise", copied_habit.name
    assert_equal @user, copied_habit.user
    assert_equal 1, copied_habit.month
    assert_equal 2025, copied_habit.year
    assert_equal 1, copied_habit.position
  end

  test "copy_from_previous_month should handle January to previous year December lookup" do
    # Create habit for December 2023
    Habit.create!(name: "Exercise", user: @user, month: 12, year: 2023, position: 1, check_type: "blots")

    # Copy to January 2024 (should look back to December 2023)
    copied_habits = Habit.copy_from_previous_month(@user, 2024, 1)

    assert_equal 1, copied_habits.length
    copied_habit = copied_habits.first
    assert_equal "Exercise", copied_habit.name
    assert_equal @user, copied_habit.user
    assert_equal 1, copied_habit.month
    assert_equal 2024, copied_habit.year
  end

  test "copy_from_previous_month should return empty array when no previous habits exist" do
    # No habits exist for previous month
    copied_habits = Habit.copy_from_previous_month(@user, 2024, 8)

    assert_equal [], copied_habits
    assert_kind_of Array, copied_habits
  end

  test "copy_from_previous_month should preserve all attributes including check_type" do
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

    # Copy to August
    copied_habits = Habit.copy_from_previous_month(@user, 2024, 8)
    copied_habit = copied_habits.first

    assert_equal "Complex Habit", copied_habit.name
    assert_equal @user, copied_habit.user
    assert_equal 8, copied_habit.month  # Should be updated
    assert_equal 2024, copied_habit.year  # Should stay same in this case
    assert_equal 5, copied_habit.position  # Should be preserved
    refute copied_habit.active  # Should preserve false value
    assert_equal "blots", copied_habit.check_type  # Should be preserved
  end

  # Check type enum tests
  test "should have check_type enum with x_marks and blots" do
    assert_respond_to Habit, :check_types

    expected_types = {
      "x_marks" => 0,
      "blots" => 1
    }

    assert_equal expected_types, Habit.check_types
  end

  test "should require check_type" do
    habit = Habit.new(@habit_attributes.except(:check_type))
    refute habit.valid?
    assert_includes habit.errors[:check_type], "can't be blank"
  end

  test "should allow setting check_type to valid values" do
    Habit.check_types.keys.each do |check_type|
      habit = Habit.new(@habit_attributes.merge(check_type: check_type))
      habit.valid? # May fail for other reasons, but check_type should be valid
      refute_includes habit.errors[:check_type], "can't be blank"
    end
  end

  test "should reject invalid check_type values" do
    assert_raises(ArgumentError) do
      Habit.new(@habit_attributes.merge(check_type: "invalid_type"))
    end
  end

  test "should keep manually set check_type during creation" do
    habit = Habit.new(@habit_attributes.merge(check_type: "blots"))
    habit.save!

    # Should keep the manually set type
    assert_equal "blots", habit.check_type
  end

  test "should not change check_type after creation" do
    habit = Habit.create!(@habit_attributes.merge(check_type: "x_marks"))
    original_check_type = habit.check_type

    # Update the habit
    habit.update!(name: "Updated Name")
    habit.reload

    # Check type should remain the same
    assert_equal original_check_type, habit.check_type
  end

  # Check type copying behavior tests
  test "copy_from_previous_month should preserve check_type from original" do
    # Create habits for July 2024 with specific check types
    Habit.create!(name: "Exercise", user: @user, month: 7, year: 2024, position: 1, check_type: "x_marks")
    Habit.create!(name: "Read", user: @user, month: 7, year: 2024, position: 2, check_type: "blots")

    # Copy to August 2024
    copied_habits = Habit.copy_from_previous_month(@user, 2024, 8)

    # Should preserve the check types from originals
    exercise_copy = copied_habits.find { |h| h.name == "Exercise" }
    read_copy = copied_habits.find { |h| h.name == "Read" }

    assert_equal "x_marks", exercise_copy.check_type
    assert_equal "blots", read_copy.check_type
  end

  test "each monthly habit can have explicitly set check_type" do
    # Create same habit name across different months with explicit check types
    habit_jan = Habit.create!(name: "Exercise", user: @user, month: 1, year: 2024, position: 1, check_type: "x_marks")
    habit_feb = Habit.create!(name: "Exercise", user: @user, month: 2, year: 2024, position: 1, check_type: "blots")
    habit_mar = Habit.create!(name: "Exercise", user: @user, month: 3, year: 2024, position: 1, check_type: "x_marks")

    # Each should have its explicitly set check_type
    assert_equal "x_marks", habit_jan.check_type
    assert_equal "blots", habit_feb.check_type
    assert_equal "x_marks", habit_mar.check_type
  end
end
