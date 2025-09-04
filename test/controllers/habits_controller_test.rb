require "test_helper"

class HabitsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)  # Use fixture user

    # Sign in the user
    post session_url, params: {
      email_address: @user.email_address,
      password: "password"  # Fixture password
    }
  end

  test "should create habit with valid name" do
    assert_difference "Habit.count", 1 do
      post habits_path, params: { name: "Test Habit" }
    end

    habit = Habit.last
    current_date = Date.current

    # Check habit attributes
    assert_equal "Test Habit", habit.name
    assert_equal @user, habit.user
    assert_equal current_date.year, habit.year
    assert_equal current_date.month, habit.month
    assert_equal 1, habit.position
    assert_equal "x_marks", habit.check_type
    assert habit.active

    # Check redirect
    assert_redirected_to settings_path
  end

  test "should create habit entries for all days of month" do
    current_date = Date.current
    days_in_month = Date.new(current_date.year, current_date.month, -1).day

    assert_difference "HabitEntry.count", days_in_month do
      post habits_path, params: { name: "Test Habit" }
    end

    habit = Habit.last

    # Check that entries exist for each day
    (1..days_in_month).each do |day|
      entry = habit.habit_entries.find_by(day: day)
      assert entry, "Entry for day #{day} should exist"
      assert_not entry.completed, "Entry should start as not completed"
    end
  end

  test "should auto-increment position for new habits" do
    # Create first habit
    post habits_path, params: { name: "First Habit" }
    first_habit = Habit.last
    assert_equal 1, first_habit.position

    # Create second habit
    post habits_path, params: { name: "Second Habit" }
    second_habit = Habit.last
    assert_equal 2, second_habit.position

    # Create third habit
    post habits_path, params: { name: "Third Habit" }
    third_habit = Habit.last
    assert_equal 3, third_habit.position
  end

  test "should handle empty name" do
    assert_no_difference "Habit.count" do
      post habits_path, params: { name: "" }
    end

    assert_redirected_to settings_path
  end

  test "should handle missing name parameter" do
    assert_no_difference "Habit.count" do
      post habits_path, params: {}
    end

    assert_redirected_to settings_path
  end

  test "should require authentication" do
    # Sign out the user
    delete session_url

    assert_no_difference "Habit.count" do
      post habits_path, params: { name: "Test Habit" }
    end

    assert_redirected_to new_session_path
  end

  test "should create habits only for current month and year" do
    travel_to Date.new(2025, 6, 15) do  # June 15, 2025
      post habits_path, params: { name: "June Habit" }

      habit = Habit.last
      assert_equal 2025, habit.year
      assert_equal 6, habit.month
      assert_equal 30, habit.habit_entries.count  # June has 30 days
    end
  end

  test "should update habit name" do
    # Create a habit first
    post habits_path, params: { name: "Original Name" }
    habit = Habit.last

    # Update the habit
    patch habit_path(habit), params: { habit: { name: "Updated Name" } }

    habit.reload
    assert_equal "Updated Name", habit.name
    assert_redirected_to settings_path
  end

  test "should not update habit with empty name" do
    # Create a habit first
    post habits_path, params: { name: "Original Name" }
    habit = Habit.last

    # Try to update with empty name
    patch habit_path(habit), params: { habit: { name: "" } }

    habit.reload
    assert_equal "Original Name", habit.name
    assert_redirected_to settings_path
  end

  test "should soft delete habit" do
    # Create a habit first
    post habits_path, params: { name: "To Be Deleted" }
    habit = Habit.last

    # Delete the habit (soft delete)
    assert_no_difference "Habit.count" do
      delete habit_path(habit)
    end

    habit.reload
    assert_not habit.active
    assert_redirected_to settings_path
  end

  test "should require authentication for update" do
    # Create a habit while authenticated
    post habits_path, params: { name: "Test Habit" }
    habit = Habit.last

    # Sign out
    delete session_url

    # Try to update
    patch habit_path(habit), params: { habit: { name: "New Name" } }

    habit.reload
    assert_equal "Test Habit", habit.name  # Name should not change
    assert_redirected_to new_session_path
  end

  test "should require authentication for destroy" do
    # Create a habit while authenticated
    post habits_path, params: { name: "Test Habit" }
    habit = Habit.last

    # Sign out
    delete session_url

    # Try to delete
    delete habit_path(habit)

    habit.reload
    assert habit.active  # Should still be active
    assert_redirected_to new_session_path
  end

  test "should only update user's own habits" do
    user1 = users(:one)
    user2 = users(:two)

    # Create a habit for user1 (who is currently signed in)
    post habits_path, params: { name: "User 1 Habit" }
    habit1 = Habit.last
    assert_equal user1.id, habit1.user_id

    # Sign out and sign in as user2
    delete session_url
    post session_url, params: {
      email_address: user2.email_address,
      password: "password"
    }

    # Try to update user1's habit while signed in as user2
    # This should return a 404 because the habit won't be found
    patch habit_path(habit1), params: { habit: { name: "Hacked!" } }

    # Rails should render a 404 when RecordNotFound is raised
    assert_response :not_found

    habit1.reload
    assert_equal "User 1 Habit", habit1.name
  end

  test "should only delete user's own habits" do
    user1 = users(:one)
    user2 = users(:two)

    # Create a habit for the current user (users(:one))
    post habits_path, params: { name: "User 1 Habit" }
    habit1 = Habit.last
    assert_equal user1.id, habit1.user_id

    # Sign out the current user and sign in as user2
    delete session_url
    post session_url, params: {
      email_address: user2.email_address,
      password: "password"
    }

    # Try to delete the first user's habit
    # This should return a 404 because the habit won't be found
    delete habit_path(habit1)

    # Rails should render a 404 when RecordNotFound is raised
    assert_response :not_found

    habit1.reload
    assert habit1.active  # Should still be active
  end

  test "should update habit position" do
    # Create a habit
    post habits_path, params: { name: "Test Habit" }
    habit = Habit.last
    assert_equal 1, habit.position

    # Update position - expect 200 OK for AJAX request
    patch habit_path(habit), params: { habit: { position: 5 } }

    habit.reload
    assert_equal 5, habit.position
    assert_response :ok
  end

  test "should update both name and position" do
    # Create a habit
    post habits_path, params: { name: "Old Name" }
    habit = Habit.last

    # Update both name and position
    patch habit_path(habit), params: { habit: { name: "New Name", position: 3 } }

    habit.reload
    assert_equal "New Name", habit.name
    assert_equal 3, habit.position
    assert_redirected_to settings_path
  end

  test "should create habit entries efficiently with minimal database queries" do
    # This test verifies that we use bulk insert instead of N+1 queries
    current_date = Date.current
    days_in_month = Date.new(current_date.year, current_date.month, -1).day

    # Track SQL queries during habit creation
    queries = []
    callback = ->(name, start, finish, id, payload) do
      queries << payload[:sql] if payload[:sql] && !payload[:sql].include?("SCHEMA")
    end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      post habits_path, params: { name: "Performance Test Habit" }
    end

    # Verify habit and entries were created
    habit = Habit.last
    assert_equal "Performance Test Habit", habit.name
    assert_equal days_in_month, habit.habit_entries.count

    # Check that we have reasonable number of queries (not N+1)
    # Expected: User lookup, Habit position query, Habit insert, bulk HabitEntry insert
    # Should be around 4-5 queries, definitely not 30+ (one per day)
    insert_all_queries = queries.select { |q| q.include?("INSERT INTO \"habit_entries\"") }
    individual_insert_queries = queries.count { |q| q.include?("INSERT INTO \"habit_entries\"") && q.include?("VALUES") }

    # Should have exactly 1 bulk insert query for habit entries, not multiple individual inserts
    assert_equal 1, insert_all_queries.length, "Expected 1 bulk insert query, but got #{insert_all_queries.length}"

    # Verify all entries have proper attributes set (including styles from bulk insert)
    habit.habit_entries.each do |entry|
      assert_not_nil entry.checkbox_style, "Checkbox style should be set"
      assert_not_nil entry.check_style, "Check style should be set"
      assert_not_nil entry.created_at, "Created timestamp should be set"
      assert_not_nil entry.updated_at, "Updated timestamp should be set"
    end
  end
end
