require "test_helper"

class ETagGeneratorTest < ActiveSupport::TestCase
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

  test "generates consistent ETag for same habit data" do
    Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    etag1 = ETagGenerator.call(user: @user, year: 2025, month: 10)
    etag2 = ETagGenerator.call(user: @user, year: 2025, month: 10)

    assert_equal etag1, etag2, "ETag should be consistent for identical data"
  end

  test "generates different ETag when habit data changes" do
    habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    etag1 = ETagGenerator.call(user: @user, year: 2025, month: 10)

    # Change habit data
    habit.update!(name: "Evening Exercise")

    etag2 = ETagGenerator.call(user: @user, year: 2025, month: 10)

    assert_not_equal etag1, etag2, "ETag should change when habit data changes"
  end

  test "generates different ETag for different users" do
    other_user = User.create!(
      email_address: "other@example.com",
      password: "secure_password123",
      onboarding_state: :completed
    )

    Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    Habit.create!(
      user: other_user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    etag1 = ETagGenerator.call(user: @user, year: 2025, month: 10)
    etag2 = ETagGenerator.call(user: other_user, year: 2025, month: 10)

    assert_not_equal etag1, etag2, "ETag should be different for different users"
  end

  test "generates different ETag for different months" do
    Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    Habit.create!(
      user: @user,
      name: "Evening Run",
      year: 2025,
      month: 9,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    etag_october = ETagGenerator.call(user: @user, year: 2025, month: 10)
    etag_september = ETagGenerator.call(user: @user, year: 2025, month: 9)

    assert_not_equal etag_october, etag_september, "ETag should be different for different months"
  end

  test "includes habit entry updates in ETag calculation" do
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
      completed: false
    )

    etag1 = ETagGenerator.call(user: @user, year: 2025, month: 10)

    # Update habit entry
    entry.update!(completed: true)

    etag2 = ETagGenerator.call(user: @user, year: 2025, month: 10)

    assert_not_equal etag1, etag2, "ETag should change when habit entries are updated"
  end

  test "includes last_modified timestamp in ETag calculation" do
    Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    timestamp1 = 1.hour.ago
    timestamp2 = Time.current

    etag1 = ETagGenerator.call(user: @user, year: 2025, month: 10, last_modified: timestamp1)
    etag2 = ETagGenerator.call(user: @user, year: 2025, month: 10, last_modified: timestamp2)

    assert_not_equal etag1, etag2, "ETag should change when last_modified timestamp changes"
  end

  test "handles nil last_modified gracefully" do
    Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    etag_with_nil = ETagGenerator.call(user: @user, year: 2025, month: 10, last_modified: nil)
    etag_without_param = ETagGenerator.call(user: @user, year: 2025, month: 10)

    assert_equal etag_with_nil, etag_without_param, "ETag should be same with nil last_modified and without parameter"
  end
end
