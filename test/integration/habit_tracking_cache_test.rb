require "test_helper"

class HabitTrackingCacheTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email_address: "test@example.com",
      password: "secure_password123",
      onboarding_state: :completed
    )

    # Sign in the user
    post session_url, params: {
      email_address: @user.email_address,
      password: "secure_password123"
    }

    # Freeze time for consistent testing
    travel_to Time.zone.local(2025, 10, 1, 12, 0, 0)
  end

  def teardown
    travel_back
  end

  # Task 3.1: Write failing test for ETag change when habits are updated
  test "ETag changes when habit is created" do
    # Get initial ETag (no habits)
    get habit_entries_month_path(year: 2025, month: 10)
    etag_before = response.headers["ETag"]

    # Create a habit
    Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # Get ETag after habit creation
    get habit_entries_month_path(year: 2025, month: 10)
    etag_after = response.headers["ETag"]

    assert_not_equal etag_before, etag_after, "ETag should change when habit is created"
  end

  test "ETag changes when habit is updated" do
    habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # Get initial ETag
    get habit_entries_month_path(year: 2025, month: 10)
    etag_before = response.headers["ETag"]

    # Update the habit
    travel 1.minute
    habit.update!(name: "Evening Exercise")

    # Get ETag after habit update
    get habit_entries_month_path(year: 2025, month: 10)
    etag_after = response.headers["ETag"]

    assert_not_equal etag_before, etag_after, "ETag should change when habit is updated"
  end

  test "ETag changes when habit is deleted (soft delete)" do
    habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # Get initial ETag
    get habit_entries_month_path(year: 2025, month: 10)
    etag_before = response.headers["ETag"]

    # Soft delete the habit
    travel 1.minute
    habit.update!(active: false)

    # Get ETag after habit deletion
    get habit_entries_month_path(year: 2025, month: 10)
    etag_after = response.headers["ETag"]

    assert_not_equal etag_before, etag_after, "ETag should change when habit is soft deleted"
  end

  test "ETag changes when habit position is updated" do
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
      check_type: :x_marks
    )

    # Get initial ETag
    get habit_entries_month_path(year: 2025, month: 10)
    etag_before = response.headers["ETag"]

    # Update habit positions (use a safe approach to avoid validation conflicts)
    travel 1.minute
    habit1.update!(position: 3)  # Move to a safe position first
    habit2.update!(position: 1)
    habit1.update!(position: 2)

    # Get ETag after position changes
    get habit_entries_month_path(year: 2025, month: 10)
    etag_after = response.headers["ETag"]

    assert_not_equal etag_before, etag_after, "ETag should change when habit positions are updated"
  end

  test "Last-Modified changes when habit is updated" do
    habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # Get initial Last-Modified
    get habit_entries_month_path(year: 2025, month: 10)
    last_modified_before = response.headers["Last-Modified"]

    # Update the habit
    travel 1.minute
    habit.update!(name: "Evening Exercise")

    # Get Last-Modified after habit update
    get habit_entries_month_path(year: 2025, month: 10)
    last_modified_after = response.headers["Last-Modified"]

    assert_not_equal last_modified_before, last_modified_after, "Last-Modified should change when habit is updated"
  end

  # Additional edge case tests to verify comprehensive cache invalidation
  test "cache invalidation works across different months" do
    # Create habit in October
    habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # Get ETag for October
    get habit_entries_month_path(year: 2025, month: 10)
    october_etag_before = response.headers["ETag"]

    # Get ETag for November (different month, should be different)
    get habit_entries_month_path(year: 2025, month: 11)
    november_etag = response.headers["ETag"]

    assert_not_equal october_etag_before, november_etag, "ETags should be different for different months"

    # Update the October habit
    travel 1.minute
    habit.update!(name: "Evening Exercise")

    # Check that October ETag changed but November ETag remains the same
    get habit_entries_month_path(year: 2025, month: 10)
    october_etag_after = response.headers["ETag"]

    get habit_entries_month_path(year: 2025, month: 11)
    november_etag_after = response.headers["ETag"]

    assert_not_equal october_etag_before, october_etag_after, "October ETag should change when October habit is updated"
    assert_equal november_etag, november_etag_after, "November ETag should not change when October habit is updated"
  end

  test "ETag changes when habit check_type is updated" do
    habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # Get initial ETag
    get habit_entries_month_path(year: 2025, month: 10)
    etag_before = response.headers["ETag"]

    # Update check_type
    travel 1.minute
    habit.update!(check_type: :blots)

    # Get ETag after check_type update
    get habit_entries_month_path(year: 2025, month: 10)
    etag_after = response.headers["ETag"]

    assert_not_equal etag_before, etag_after, "ETag should change when habit check_type is updated"
  end

  # Task 3.2: Write failing test for ETag change when habit entries are updated
  test "ETag changes when habit entry is created" do
    habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # Get initial ETag (entries auto-created with completed: false)
    get habit_entries_month_path(year: 2025, month: 10)
    etag_before = response.headers["ETag"]

    # Update a habit entry
    travel 1.minute
    entry = HabitEntry.find_by!(habit: habit, day: 1)
    entry.update!(completed: true)

    # Get ETag after entry creation
    get habit_entries_month_path(year: 2025, month: 10)
    etag_after = response.headers["ETag"]

    assert_not_equal etag_before, etag_after, "ETag should change when habit entry is created"
  end

  test "ETag changes when habit entry completion status is updated" do
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

    # Get initial ETag
    get habit_entries_month_path(year: 2025, month: 10)
    etag_before = response.headers["ETag"]

    # Update entry completion status
    travel 1.minute
    entry.update!(completed: true)

    # Get ETag after entry update
    get habit_entries_month_path(year: 2025, month: 10)
    etag_after = response.headers["ETag"]

    assert_not_equal etag_before, etag_after, "ETag should change when habit entry completion is updated"
  end

  test "ETag changes when habit entry is deleted" do
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

    # Get initial ETag
    get habit_entries_month_path(year: 2025, month: 10)
    etag_before = response.headers["ETag"]

    # Delete the entry
    travel 1.minute
    entry.destroy!

    # Get ETag after entry deletion
    get habit_entries_month_path(year: 2025, month: 10)
    etag_after = response.headers["ETag"]

    assert_not_equal etag_before, etag_after, "ETag should change when habit entry is deleted"
  end

  test "Last-Modified changes when habit entry is updated" do
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

    # Get initial Last-Modified
    get habit_entries_month_path(year: 2025, month: 10)
    last_modified_before = response.headers["Last-Modified"]

    # Update entry
    travel 1.minute
    entry.update!(completed: true)

    # Get Last-Modified after entry update
    get habit_entries_month_path(year: 2025, month: 10)
    last_modified_after = response.headers["Last-Modified"]

    assert_not_equal last_modified_before, last_modified_after, "Last-Modified should change when habit entry is updated"
  end

  test "habit entry updates should trigger parent habit timestamp update" do
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

    # Get initial habit timestamp
    initial_habit_timestamp = habit.updated_at

    # Update entry
    travel 1.minute
    entry.update!(completed: true)

    # Check if habit timestamp was updated (this might fail if no touch callback exists)
    habit.reload
    updated_habit_timestamp = habit.updated_at

    assert_not_equal initial_habit_timestamp, updated_habit_timestamp,
      "Habit updated_at should change when its entries are updated (requires touch callback)"
  end

  test "habit entry updates in different months should not affect other months" do
    # Create habits in both October and November
    october_habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    november_habit = Habit.create!(
      user: @user,
      name: "Reading",
      year: 2025,
      month: 11,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # Create entries for both
    october_entry = HabitEntry.create!(habit: october_habit, day: 1, completed: false)
    november_entry = HabitEntry.create!(habit: november_habit, day: 1, completed: false)

    # Get initial ETags for both months
    get habit_entries_month_path(year: 2025, month: 10)
    october_etag_before = response.headers["ETag"]

    get habit_entries_month_path(year: 2025, month: 11)
    november_etag_before = response.headers["ETag"]

    # Update only October entry
    travel 1.minute
    october_entry.update!(completed: true)

    # Check ETags after October entry update
    get habit_entries_month_path(year: 2025, month: 10)
    october_etag_after = response.headers["ETag"]

    get habit_entries_month_path(year: 2025, month: 11)
    november_etag_after = response.headers["ETag"]

    assert_not_equal october_etag_before, october_etag_after, "October ETag should change when October entry is updated"
    assert_equal november_etag_before, november_etag_after, "November ETag should not change when October entry is updated"
  end

  # Task 3.4: Verify habit_entry updates trigger ETag changes through controller actions
  test "ETag changes when habit entry is updated via controller" do
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

    # Get initial ETag
    get habit_entries_month_path(year: 2025, month: 10)
    etag_before = response.headers["ETag"]

    # Update entry via controller (simulates real user interaction)
    travel 1.minute
    patch habit_entry_path(entry), params: { habit_entry: { completed: true } }
    assert_response :no_content

    # Get ETag after controller update
    get habit_entries_month_path(year: 2025, month: 10)
    etag_after = response.headers["ETag"]

    assert_not_equal etag_before, etag_after, "ETag should change when habit entry is updated via controller"
  end

  test "Last-Modified changes when habit entry is updated via controller" do
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

    # Get initial Last-Modified
    get habit_entries_month_path(year: 2025, month: 10)
    last_modified_before = response.headers["Last-Modified"]

    # Update entry via controller
    travel 1.minute
    patch habit_entry_path(entry), params: { habit_entry: { completed: true } }
    assert_response :no_content

    # Get Last-Modified after controller update
    get habit_entries_month_path(year: 2025, month: 10)
    last_modified_after = response.headers["Last-Modified"]

    assert_not_equal last_modified_before, last_modified_after, "Last-Modified should change when habit entry is updated via controller"
  end

  test "multiple habit entry updates produce different ETags" do
    habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    entry1 = HabitEntry.create!(habit: habit, day: 1, completed: false)
    entry2 = HabitEntry.create!(habit: habit, day: 2, completed: false)

    # Get initial ETag
    get habit_entries_month_path(year: 2025, month: 10)
    etag_initial = response.headers["ETag"]

    # Update first entry
    travel 1.minute
    patch habit_entry_path(entry1), params: { habit_entry: { completed: true } }
    get habit_entries_month_path(year: 2025, month: 10)
    etag_after_first = response.headers["ETag"]

    # Update second entry
    travel 1.minute
    patch habit_entry_path(entry2), params: { habit_entry: { completed: true } }
    get habit_entries_month_path(year: 2025, month: 10)
    etag_after_second = response.headers["ETag"]

    assert_not_equal etag_initial, etag_after_first, "ETag should change after first entry update"
    assert_not_equal etag_after_first, etag_after_second, "ETag should change after second entry update"
    assert_not_equal etag_initial, etag_after_second, "Final ETag should be different from initial"
  end


  test "cache invalidation works with 304 responses" do
    habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    entry = HabitEntry.create!(habit: habit, day: 1, completed: false)

    # Get initial ETag and Last-Modified
    get habit_entries_month_path(year: 2025, month: 10)
    etag = response.headers["ETag"]
    last_modified = response.headers["Last-Modified"]

    # Request with matching headers should return 304
    get habit_entries_month_path(year: 2025, month: 10), headers: {
      "If-None-Match" => etag,
      "If-Modified-Since" => last_modified
    }
    assert_response :not_modified

    # Update entry
    travel 1.minute
    patch habit_entry_path(entry), params: { habit_entry: { completed: true } }

    # Request with old headers should now return 200 (data changed)
    get habit_entries_month_path(year: 2025, month: 10), headers: {
      "If-None-Match" => etag,
      "If-Modified-Since" => last_modified
    }
    assert_response :success
    assert_not_equal etag, response.headers["ETag"], "ETag should be different after entry update"
  end
end
