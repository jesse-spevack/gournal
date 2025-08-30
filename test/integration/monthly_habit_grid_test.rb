require "test_helper"

class MonthlyHabitGridTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email_address: "test@example.com",
      password: "secure_password123"
    )
    @other_user = User.create!(
      email_address: "other@example.com",
      password: "secure_password123"
    )

    sign_in_as(@user)
  end

  # Integration test for full monthly habit grid workflow
  test "complete habit tracking workflow for current month" do
    # Visit root path (should show current month grid)
    get root_path
    assert_response :success
    assert_select "h1", text: /#{Date.current.strftime("%B %Y")}/i

    # Initially no habits should exist
    assert_select ".habit-row", count: 0
    assert_select "p", text: /no habits/i

    # Create first habit
    get new_habit_path
    assert_response :success

    post habits_path, params: {
      habit: {
        name: "Morning Exercise",
        month: Date.current.month,
        year: Date.current.year,
        check_type: "x_marks"
      }
    }

    follow_redirect!
    assert_response :success

    # Should see the habit in the grid
    assert_select ".habit-row", count: 1
    assert_select ".habit-name", text: "Morning Exercise"

    # Should see checkboxes for each day of the month
    days_in_month = Date.current.end_of_month.day
    assert_select ".day-cell", count: days_in_month
    assert_select ".checkbox[data-completed='false']", count: days_in_month

    # Create second habit
    get new_habit_path
    post habits_path, params: {
      habit: {
        name: "Evening Reading",
        month: Date.current.month,
        year: Date.current.year,
        check_type: "blots"
      }
    }

    follow_redirect!

    # Should see both habits
    assert_select ".habit-row", count: 2
    assert_select ".habit-name", text: "Morning Exercise"
    assert_select ".habit-name", text: "Evening Reading"

    # Should see checkboxes for all habits × days
    assert_select ".day-cell", count: days_in_month * 2
    assert_select ".checkbox[data-completed='false']", count: days_in_month * 2
  end

  test "habit entry toggling via AJAX" do
    habit = create_habit_for_current_month("Daily Yoga")

    get root_path
    assert_response :success

    # Get the habit entry for day 15 (should auto-create if not exists)
    entry = HabitEntry.find_or_create_by(habit: habit, day: 15)

    # Toggle completion via AJAX
    patch habit_entry_path(entry),
          params: { habit_entry: { completed: true } },
          headers: { "Accept" => "application/json" }

    assert_response :success
    assert_equal "application/json", response.media_type

    json_response = JSON.parse(response.body)
    assert json_response["completed"]

    entry.reload
    assert entry.completed

    # Toggle back to false
    patch habit_entry_path(entry),
          params: { habit_entry: { completed: false } },
          headers: { "Accept" => "application/json" }

    assert_response :success
    entry.reload
    refute entry.completed
  end

  test "habit entry toggling via Turbo Stream" do
    habit = create_habit_for_current_month("Meditation")

    get root_path
    assert_response :success

    entry = HabitEntry.find_or_create_by(habit: habit, day: 10)

    # Toggle via Turbo Stream
    patch habit_entry_path(entry),
          params: { habit_entry: { completed: true } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_match /turbo-stream/, response.body
    assert_match /replace/, response.body

    entry.reload
    assert entry.completed
  end

  test "future date prevention in grid" do
    habit = create_habit_for_current_month("Water Plants")

    get root_path

    # Try to check tomorrow's date
    tomorrow = Date.current.tomorrow
    if tomorrow.month == Date.current.month
      # Only test if tomorrow is in current month
      patch habit_entry_by_habit_and_day_path(habit_id: habit.id, day: tomorrow.day),
            params: { habit_entry: { completed: true } },
            headers: { "Accept" => "application/json" }

      assert_response :unprocessable_entity

      json_response = JSON.parse(response.body)
      assert_includes json_response["error"], "Cannot complete future dates"

      # Verify no entry was created
      refute HabitEntry.exists?(habit: habit, day: tomorrow.day)
    end
  end

  test "month navigation workflow" do
    # Create habits for different months
    current_habit = create_habit_for_current_month("Current Month Habit")

    next_month = Date.current.next_month
    next_month_habit = Habit.create!(
      name: "Next Month Habit",
      month: next_month.month,
      year: next_month.year,
      position: 1,
      user: @user,
      check_type: "blots"
    )

    # Start at root (current month)
    get root_path
    assert_select ".habit-name", text: "Current Month Habit"
    refute_select ".habit-name", text: "Next Month Habit"

    # Navigate to next month from current month context
    current_date = Date.current
    get habits_path, params: {
      nav: "next",
      year: current_date.year,
      month: current_date.month
    }
    assert_response :success
    assert_select "h1", text: /#{next_month.strftime("%B %Y")}/i
    assert_select ".habit-name", text: "Next Month Habit"
    refute_select ".habit-name", text: "Current Month Habit"

    # Navigate back to current month from next month context
    get habits_path, params: {
      nav: "previous",
      year: next_month.year,
      month: next_month.month
    }
    assert_response :success
    assert_select "h1", text: /#{current_date.strftime("%B %Y")}/i
    assert_select ".habit-name", text: "Current Month Habit"
    refute_select ".habit-name", text: "Next Month Habit"
  end

  test "direct month/year navigation" do
    # Create habit for specific month
    march_habit = Habit.create!(
      name: "March Habit",
      month: 3,
      year: 2024,
      position: 1,
      user: @user,
      check_type: "x_marks"
    )

    # Navigate directly to March 2024
    get habit_path(1, year: 2024, month: 3)
    assert_response :success
    assert_select "h1", text: /March 2024/i
    assert_select ".habit-name", text: "March Habit"

    # Should show March's calendar (31 days)
    assert_select ".day-cell", count: 31
  end

  test "habit CRUD operations in grid context" do
    # Start with empty grid
    get root_path
    assert_select ".habit-row", count: 0

    # Create habit
    post habits_path, params: {
      habit: {
        name: "Test Habit",
        month: Date.current.month,
        year: Date.current.year,
        check_type: "x_marks"
      }
    }

    follow_redirect!
    habit = Habit.last
    assert_select ".habit-name", text: "Test Habit"

    # Edit habit
    get edit_habit_path(habit)
    assert_response :success

    patch habit_path(habit), params: {
      habit: { name: "Updated Test Habit" }
    }

    follow_redirect!
    assert_select ".habit-name", text: "Updated Test Habit"

    # Delete habit
    delete habit_path(habit)
    follow_redirect!
    assert_select ".habit-row", count: 0
  end

  test "user isolation in grid" do
    # Create habits for both users
    user_habit = create_habit_for_current_month("User Habit")

    sign_in_as(@other_user)
    other_user_habit = create_habit_for_current_month("Other User Habit", user: @other_user)

    # Other user should only see their own habit
    get root_path
    assert_select ".habit-name", text: "Other User Habit"
    refute_select ".habit-name", text: "User Habit"

    # Switch back to original user
    sign_in_as(@user)
    get root_path
    assert_select ".habit-name", text: "User Habit"
    refute_select ".habit-name", text: "Other User Habit"
  end

  test "grid displays habit entries correctly" do
    habit = create_habit_for_current_month("Display Test")

    # Create some habit entries
    HabitEntry.create!(habit: habit, day: 1, completed: true)
    HabitEntry.create!(habit: habit, day: 5, completed: false)
    HabitEntry.create!(habit: habit, day: 10, completed: true)

    get root_path
    assert_response :success

    # Should show completed and uncompleted checkboxes
    assert_select ".checkbox[data-completed='true']", count: 2
    # For 1 habit over all days in month: total days - 2 completed = uncompleted
    days_in_month = Date.current.end_of_month.day
    assert_select ".checkbox[data-completed='false']", count: (days_in_month - 2)
  end

  test "habit positioning is maintained in grid" do
    # Create habits in specific order
    habit1 = Habit.create!(
      name: "First Habit",
      month: Date.current.month,
      year: Date.current.year,
      position: 1,
      user: @user,
      check_type: "x_marks"
    )

    habit3 = Habit.create!(
      name: "Third Habit",
      month: Date.current.month,
      year: Date.current.year,
      position: 3,
      user: @user,
      check_type: "blots"
    )

    habit2 = Habit.create!(
      name: "Second Habit",
      month: Date.current.month,
      year: Date.current.year,
      position: 2,
      user: @user,
      check_type: "x_marks"
    )

    get root_path
    assert_response :success

    # Should appear in position order, not creation order
    habit_names = css_select(".habit-name").map(&:content)
    assert_equal [ "First Habit", "Second Habit", "Third Habit" ], habit_names
  end

  test "different check types display different visual styles" do
    x_habit = Habit.create!(
      name: "X Marks Habit",
      month: Date.current.month,
      year: Date.current.year,
      position: 1,
      user: @user,
      check_type: "x_marks"
    )

    blots_habit = Habit.create!(
      name: "Blots Habit",
      month: Date.current.month,
      year: Date.current.year,
      position: 2,
      user: @user,
      check_type: "blots"
    )

    # Create entries for both
    x_entry = HabitEntry.create!(habit: x_habit, day: 1, completed: true)
    blots_entry = HabitEntry.create!(habit: blots_habit, day: 1, completed: true)

    get root_path
    assert_response :success

    # Should have different visual indicators
    # This would depend on the actual CSS classes/styling implemented
    assert_select ".checkbox[data-check-type='x_marks']"
    assert_select ".checkbox[data-check-type='blots']"
  end

  test "error handling in grid context" do
    # Test various error conditions

    # Invalid month navigation
    get habits_path, params: { month: 13, year: 2024 }
    assert_redirected_to habits_path
    assert_equal "Invalid month or year.", flash[:alert]

    # Invalid year navigation
    get habits_path, params: { month: 6, year: "invalid" }
    assert_redirected_to habits_path
    assert_equal "Invalid month or year.", flash[:alert]

    # Non-existent habit entry toggle
    patch habit_entry_path(999999),
          params: { habit_entry: { completed: true } },
          headers: { "Accept" => "application/json" }
    assert_response :not_found
  end

  test "grid performance with many habits and entries" do
    # Create multiple habits with entries
    habits = []
    20.times do |i|
      habit = Habit.create!(
        name: "Habit #{i}",
        month: Date.current.month,
        year: Date.current.year,
        position: i + 1,
        user: @user,
        check_type: i.even? ? "x_marks" : "blots"
      )
      habits << habit

      # Create entries for some days
      [ 1, 5, 10, 15, 20 ].each do |day|
        HabitEntry.create!(habit: habit, day: day, completed: [ true, false ].sample)
      end
    end

    # Grid should load efficiently
    get root_path
    assert_response :success

    # Should display all habits
    assert_select ".habit-row", count: 20

    # Should handle the large grid gracefully
    assert_select ".checkbox", minimum: 20 * Date.current.end_of_month.day
  end

  private

  def sign_in_as(user)
    post session_url, params: {
      email_address: user.email_address,
      password: "secure_password123"
    }
  end

  def create_habit_for_current_month(name, user: nil)
    target_user = user || @user
    # Find the next available position for this user in current month
    max_position = target_user.habits
                        .where(year: Date.current.year, month: Date.current.month)
                        .maximum(:position) || 0

    Habit.create!(
      name: name,
      month: Date.current.month,
      year: Date.current.year,
      position: max_position + 1,
      user: target_user,
      check_type: "x_marks"
    )
  end
end
