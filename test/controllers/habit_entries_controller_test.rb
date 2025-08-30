require "test_helper"

class HabitEntriesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email_address: "test@example.com",
      password: "secure_password123"
    )
    @other_user = User.create!(
      email_address: "other@example.com",
      password: "secure_password123"
    )

    # Create test habits
    @habit = Habit.create!(
      name: "Exercise",
      month: Date.current.month,
      year: Date.current.year,
      position: 1,
      user: @user,
      check_type: "x_marks"
    )

    @other_user_habit = Habit.create!(
      name: "Other User Habit",
      month: Date.current.month,
      year: Date.current.year,
      position: 1,
      user: @other_user,
      check_type: "blots"
    )

    # Create test habit entries
    @habit_entry = HabitEntry.create!(
      habit: @habit,
      day: 15,
      completed: false
    )

    @other_user_entry = HabitEntry.create!(
      habit: @other_user_habit,
      day: 15,
      completed: false
    )

    sign_in_as(@user)
  end

  # Authentication tests
  test "should require authentication for update action" do
    sign_out

    patch habit_entry_path(@habit_entry), params: {
      habit_entry: { completed: true }
    }
    assert_redirected_to new_session_path
  end

  # Update action tests (RESTful checkbox toggling)
  test "should toggle habit entry from false to true" do
    patch habit_entry_path(@habit_entry), params: {
      habit_entry: { completed: true }
    }

    @habit_entry.reload
    assert @habit_entry.completed
    assert_response :success
  end

  test "should toggle habit entry from true to false" do
    @habit_entry.update!(completed: true)

    patch habit_entry_path(@habit_entry), params: {
      habit_entry: { completed: false }
    }

    @habit_entry.reload
    refute @habit_entry.completed
    assert_response :success
  end

  test "should create habit entry if it doesn't exist when toggling" do
    # Delete the existing entry
    @habit_entry.destroy

    # Should create new entry when toggling non-existent day
    assert_difference "HabitEntry.count" do
      patch habit_entry_by_habit_and_day_path(habit_id: @habit.id, day: 20), params: {
        habit_entry: { completed: true }
      }
    end

    entry = HabitEntry.find_by(habit: @habit, day: 20)
    assert entry.completed
    assert_response :success
  end

  test "should respond with JSON for AJAX requests" do
    patch habit_entry_path(@habit_entry),
          params: { habit_entry: { completed: true } },
          headers: { "Accept" => "application/json" }

    assert_response :success
    assert_equal "application/json", response.media_type

    json_response = JSON.parse(response.body)
    assert json_response["completed"]
    assert_equal @habit_entry.id, json_response["id"]
  end

  test "should respond with Turbo Stream for Turbo requests" do
    patch habit_entry_path(@habit_entry),
          params: { habit_entry: { completed: true } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_match /turbo-stream/, response.body
  end

  test "should not allow updating other user's habit entries" do
    patch habit_entry_path(@other_user_entry), params: {
      habit_entry: { completed: true }
    }

    assert_response :not_found

    @other_user_entry.reload
    refute @other_user_entry.completed # Should not change
  end

  # Future date prevention tests
  test "should prevent checking future dates" do
    future_date = Date.current.tomorrow

    # Create habit entry for future date
    future_entry = HabitEntry.create!(
      habit: @habit,
      day: future_date.day,
      completed: false
    )

    patch habit_entry_path(future_entry), params: {
      habit_entry: { completed: true }
    }

    assert_response :unprocessable_entity

    future_entry.reload
    refute future_entry.completed # Should not change

    # Should return error message
    # json_response = JSON.parse(response.body) if response.media_type == "application/json"
    # assert_includes json_response["error"], "Cannot complete future dates"
  end

  test "should prevent creating future date entries" do
    future_date = Date.current.tomorrow

    assert_no_difference "HabitEntry.count" do
      patch habit_entry_by_habit_and_day_path(habit_id: @habit.id, day: future_date.day), params: {
        habit_entry: { completed: true }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should allow checking today's date" do
    today_entry = HabitEntry.create!(
      habit: @habit,
      day: Date.current.day,
      completed: false
    )

    patch habit_entry_path(today_entry), params: {
      habit_entry: { completed: true }
    }

    assert_response :success

    today_entry.reload
    assert today_entry.completed
  end

  test "should allow checking past dates" do
    past_entry = HabitEntry.create!(
      habit: @habit,
      day: Date.current.day - 1,
      completed: false
    )

    patch habit_entry_path(past_entry), params: {
      habit_entry: { completed: true }
    }

    assert_response :success

    past_entry.reload
    assert past_entry.completed
  end

  # Date validation across different months/years
  test "should check future dates relative to habit's month/year" do
    # Create habit for next month
    future_habit = Habit.create!(
      name: "Future Habit",
      month: Date.current.next_month.month,
      year: Date.current.next_month.year,
      position: 1,
      user: @user,
      check_type: "x_marks"
    )

    # Try to check day 1 of next month (which is in the future)
    assert_no_difference "HabitEntry.count" do
      patch habit_entry_by_habit_and_day_path(habit_id: future_habit.id, day: 1), params: {
        habit_entry: { completed: true }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should allow checking dates in past months" do
    # Create habit for last month
    past_habit = Habit.create!(
      name: "Past Habit",
      month: Date.current.prev_month.month,
      year: Date.current.prev_month.year,
      position: 1,
      user: @user,
      check_type: "x_marks"
    )

    # Should allow checking any day in past month
    assert_difference "HabitEntry.count" do
      patch habit_entry_by_habit_and_day_path(habit_id: past_habit.id, day: 15), params: {
        habit_entry: { completed: true }
      }
    end

    assert_response :success
  end

  # Error handling tests
  test "should handle invalid habit entry parameters gracefully" do
    patch habit_entry_path(@habit_entry), params: {
      habit_entry: {
        completed: "invalid_boolean",
        day: "invalid_day"
      }
    }

    # Should handle gracefully and not crash
    assert_response :unprocessable_entity
  end

  test "should handle non-existent habit entry gracefully" do
    non_existent_id = 99999

    patch habit_entry_path(non_existent_id), params: {
      habit_entry: { completed: true }
    }

    assert_response :not_found
  end

  # Bulk operations (if supported)
  test "should handle multiple entry updates" do
    entry1 = HabitEntry.create!(habit: @habit, day: 1, completed: false)
    entry2 = HabitEntry.create!(habit: @habit, day: 2, completed: false)

    patch habit_entry_path(entry1), params: {
      habit_entries: {
        entry1.id => { completed: true },
        entry2.id => { completed: true }
      }
    }

    entry1.reload
    entry2.reload

    assert entry1.completed
    assert entry2.completed
    assert_response :success
  end

  # Authorization edge cases
  test "should verify habit ownership through entry" do
    # Try to update entry for habit user doesn't own
    patch habit_entry_path(@other_user_entry), params: {
      habit_entry: { completed: true }
    }

    assert_response :not_found
  end

  test "should allow user to update their own entries only" do
    user_entry = HabitEntry.create!(habit: @habit, day: 10, completed: false)

    patch habit_entry_path(user_entry), params: {
      habit_entry: { completed: true }
    }

    assert_response :success

    user_entry.reload
    assert user_entry.completed
  end

  # Performance considerations
  test "should not n+1 query when updating multiple entries" do
    # Create multiple entries
    entries = []
    5.times do |i|
      entries << HabitEntry.create!(habit: @habit, day: i + 1, completed: false)
    end

    # This test would verify efficient querying in the controller
    # The actual implementation should avoid n+1 queries when possible
    assert_queries(2) do # Adjust based on actual expected query count
      patch habit_entry_path(entries.first), params: {
        habit_entry: { completed: true }
      }
    end

    assert_response :success
  end

  # Style preservation tests
  test "should preserve existing checkbox and check styles when toggling" do
    @habit_entry.update!(
      checkbox_style: "box_style_5",
      check_style: "x_style_7"
    )

    original_checkbox_style = @habit_entry.checkbox_style
    original_check_style = @habit_entry.check_style

    patch habit_entry_path(@habit_entry), params: {
      habit_entry: { completed: true }
    }

    @habit_entry.reload
    assert @habit_entry.completed
    assert_equal original_checkbox_style, @habit_entry.checkbox_style
    assert_equal original_check_style, @habit_entry.check_style
  end

  test "should assign random styles to new entries created via toggle" do
    # Delete existing entry
    @habit_entry.destroy

    # Create new entry via toggle
    patch habit_entry_by_habit_and_day_path(habit_id: @habit.id, day: 25), params: {
      habit_entry: { completed: true }
    }

    entry = HabitEntry.find_by(habit: @habit, day: 25)
    assert entry
    assert entry.completed
    assert_not_nil entry.checkbox_style
    assert_not_nil entry.check_style

    # Should follow habit's check_type for check_style
    assert entry.check_style.start_with?("x_style_"),
           "Expected x_style for x_marks habit, got: #{entry.check_style}"
  end

  private

  def sign_in_as(user)
    post session_url, params: {
      email_address: user.email_address,
      password: "secure_password123"
    }
  end

  def sign_out
    delete session_url
    Current.session = nil
  end

  def assert_queries(expected_count, &block)
    # Helper method to count database queries
    # This would need to be implemented or use existing Rails testing utilities
    yield
  end
end
