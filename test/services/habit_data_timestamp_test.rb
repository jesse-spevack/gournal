require "test_helper"

class HabitDataTimestampTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email_address: "test@example.com",
      password: "secure_password123",
      onboarding_state: :completed
    )

    # Freeze time for consistent testing
    travel_to Time.zone.local(2025, 10, 1, 12, 0, 0)
  end

  def teardown
    travel_back
  end

  test "returns default timestamp when no habits exist" do
    timestamp = HabitDataTimestamp.call(user: @user, year: 2025, month: 10)
    expected = Time.zone.local(2025, 10, 1).beginning_of_month

    assert_equal expected, timestamp
  end

  test "returns habit updated_at when only habits exist" do
    habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    timestamp = HabitDataTimestamp.call(user: @user, year: 2025, month: 10)

    assert_equal habit.updated_at, timestamp
  end

  test "returns entry updated_at when entry is more recent than habit" do
    habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    travel 1.minute

    entry = HabitEntry.create!(
      habit: habit,
      day: 1,
      completed: true
    )

    timestamp = HabitDataTimestamp.call(user: @user, year: 2025, month: 10)

    assert_equal entry.updated_at, timestamp
  end

  test "returns habit updated_at when habit is more recent than entry" do
    habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    entry = HabitEntry.create!(
      habit: habit,
      day: 1,
      completed: true
    )

    travel 1.minute

    habit.update!(name: "Evening Exercise")

    timestamp = HabitDataTimestamp.call(user: @user, year: 2025, month: 10)

    assert_equal habit.updated_at, timestamp
  end

  test "ignores inactive habits" do
    active_habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    travel 1.minute

    Habit.create!(
      user: @user,
      name: "Deleted Habit",
      year: 2025,
      month: 10,
      position: 2,
      active: false,
      check_type: :x_marks
    )

    timestamp = HabitDataTimestamp.call(user: @user, year: 2025, month: 10)

    assert_equal active_habit.updated_at, timestamp
  end

  test "ignores habits from different months" do
    Habit.create!(
      user: @user,
      name: "September Habit",
      year: 2025,
      month: 9,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    timestamp = HabitDataTimestamp.call(user: @user, year: 2025, month: 10)
    expected = Time.zone.local(2025, 10, 1).beginning_of_month

    assert_equal expected, timestamp
  end

  test "ignores habits from different years" do
    Habit.create!(
      user: @user,
      name: "Last Year Habit",
      year: 2024,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    timestamp = HabitDataTimestamp.call(user: @user, year: 2025, month: 10)
    expected = Time.zone.local(2025, 10, 1).beginning_of_month

    assert_equal expected, timestamp
  end

  test "ignores habits belonging to different users" do
    other_user = User.create!(
      email_address: "other@example.com",
      password: "secure_password123",
      onboarding_state: :completed
    )

    Habit.create!(
      user: other_user,
      name: "Other User Habit",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    timestamp = HabitDataTimestamp.call(user: @user, year: 2025, month: 10)
    expected = Time.zone.local(2025, 10, 1).beginning_of_month

    assert_equal expected, timestamp
  end

  test "handles multiple habits and returns most recent" do
    habit1 = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    travel 30.minutes

    habit2 = Habit.create!(
      user: @user,
      name: "Reading",
      year: 2025,
      month: 10,
      position: 2,
      active: true,
      check_type: :blots
    )

    timestamp = HabitDataTimestamp.call(user: @user, year: 2025, month: 10)

    assert_equal habit2.updated_at, timestamp
  end

  test "handles multiple entries and returns most recent" do
    habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    entry1 = HabitEntry.create!(habit: habit, day: 1, completed: true)

    travel 30.minutes

    entry2 = HabitEntry.create!(habit: habit, day: 2, completed: false)

    timestamp = HabitDataTimestamp.call(user: @user, year: 2025, month: 10)

    assert_equal entry2.updated_at, timestamp
  end

  test "returns most recent across habits and entries" do
    habit1 = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    habit2 = Habit.create!(
      user: @user,
      name: "Reading",
      year: 2025,
      month: 10,
      position: 2,
      active: true,
      check_type: :blots
    )

    entry1 = HabitEntry.create!(habit: habit1, day: 1, completed: true)

    travel 30.minutes

    entry2 = HabitEntry.create!(habit: habit2, day: 1, completed: false)

    travel 30.minutes

    habit1.update!(name: "Evening Exercise")

    timestamp = HabitDataTimestamp.call(user: @user, year: 2025, month: 10)

    assert_equal habit1.updated_at, timestamp
  end
end
