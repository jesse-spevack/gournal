require "test_helper"

class HabitEntriesControllerTest < ActionDispatch::IntegrationTest
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

    # Freeze time to October 1, 2025 for consistent testing
    travel_to Time.zone.local(2025, 10, 1, 12, 0, 0)
  end

  def teardown
    travel_back
  end

  test "shows previous month navigation link" do
    # Visit October 2025 (current month in test)
    get habit_entries_month_path(year: 2025, month: 10)
    assert_response :success

    # Check that previous month link is present
    assert_select "a[href='/habit_entries/2025/9']", text: "<"
  end

  test "shows next month navigation link when viewing past months" do
    # Visit September 2025 (past month in test)
    get habit_entries_month_path(year: 2025, month: 9)
    assert_response :success

    # Check that next month link is present
    assert_select "a[href='/habit_entries/2025/10']", text: ">"
  end

  test "does not show next month link when viewing current month" do
    # Visit current month
    current_date = Date.current
    get habit_entries_month_path(year: current_date.year, month: current_date.month)
    assert_response :success

    # Check that next month link is NOT present
    assert_select "a", text: ">", count: 0
  end

  test "navigation handles year boundaries correctly" do
    # Visit January 2025
    get habit_entries_month_path(year: 2025, month: 1)
    assert_response :success

    # Previous should be December 2024
    assert_select "a[href='/habit_entries/2024/12']", text: "<"

    # Visit December 2024
    get habit_entries_month_path(year: 2024, month: 12)
    assert_response :success

    # Next should be January 2025
    assert_select "a[href='/habit_entries/2025/1']", text: ">"
  end

  test "shows both navigation arrows when viewing a past month" do
    # Visit a past month (September 2025)
    get habit_entries_month_path(year: 2025, month: 9)
    assert_response :success

    # Should show both previous and next navigation
    assert_select "a[href='/habit_entries/2025/8']", text: "<"
    assert_select "a[href='/habit_entries/2025/10']", text: ">"
  end

  test "shows navigation in month header" do
    # Visit September 2025
    get habit_entries_month_path(year: 2025, month: 9)
    assert_response :success

    # Check that navigation appears near the month header
    assert_select "header.month-header" do
      assert_select "h1", text: /September 2025/
    end
  end

  test "does not show previous month link when viewing earliest month with habits" do
    # Create habits only for March 2025 (making it the earliest month)
    Habit.create!(
      user: @user,
      name: "Test Habit",
      year: 2025,
      month: 3,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # Visit March 2025 (the earliest month with habits)
    get habit_entries_month_path(year: 2025, month: 3)
    assert_response :success

    # Should NOT show previous month link
    assert_select "a", text: "<", count: 0
    # Should show next month link
    assert_select "a[href='/habit_entries/2025/4']", text: ">"
  end
end
