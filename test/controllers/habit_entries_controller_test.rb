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

  # ETag integration tests
  test "includes ETag header in response" do
    get habit_entries_month_path(year: 2025, month: 10)
    assert_response :success
    assert_not_nil response.headers["ETag"], "Response should include ETag header"
  end

  test "generates consistent ETag for same request" do
    # Create some habit data
    Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # First request
    get habit_entries_month_path(year: 2025, month: 10)
    etag1 = response.headers["ETag"]

    # Second request
    get habit_entries_month_path(year: 2025, month: 10)
    etag2 = response.headers["ETag"]

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

    # First request
    get habit_entries_month_path(year: 2025, month: 10)
    etag1 = response.headers["ETag"]

    # Change habit data
    habit.update!(name: "Evening Exercise")

    # Second request after change
    get habit_entries_month_path(year: 2025, month: 10)
    etag2 = response.headers["ETag"]

    assert_not_equal etag1, etag2, "ETag should change when habit data changes"
  end

  test "returns 304 Not Modified for matching ETag" do
    Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # First request to get ETag
    get habit_entries_month_path(year: 2025, month: 10)
    assert_response :success
    etag = response.headers["ETag"]

    # Second request with If-None-Match header
    get habit_entries_month_path(year: 2025, month: 10), headers: { "If-None-Match" => etag }
    assert_response :not_modified
    assert_empty response.body, "304 response should have empty body"
  end

  test "returns 200 OK when ETag does not match" do
    Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # Request with non-matching ETag
    get habit_entries_month_path(year: 2025, month: 10), headers: { "If-None-Match" => '"fake-etag"' }
    assert_response :success
    assert_not_empty response.body, "200 response should have body content"
    assert_not_nil response.headers["ETag"], "Response should include new ETag"
  end

  # Additional HTTP cache header tests for Task 2.0
  test "includes Last-Modified header in response" do
    Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    get habit_entries_month_path(year: 2025, month: 10)
    assert_response :success
    assert_not_nil response.headers["Last-Modified"], "Response should include Last-Modified header"
  end

  test "returns 304 for matching If-Modified-Since" do
    Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # First request to get Last-Modified
    get habit_entries_month_path(year: 2025, month: 10)
    assert_response :success
    last_modified = response.headers["Last-Modified"]

    # Second request with If-Modified-Since header
    get habit_entries_month_path(year: 2025, month: 10), headers: { "If-Modified-Since" => last_modified }
    assert_response :not_modified
    assert_empty response.body, "304 response should have empty body"
  end

  test "sets correct Cache-Control headers" do
    Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    get habit_entries_month_path(year: 2025, month: 10)
    assert_response :success

    # Check that appropriate cache headers are set
    assert_not_nil response.headers["ETag"], "Should have ETag header"
    assert_not_nil response.headers["Last-Modified"], "Should have Last-Modified header"

    # Verify cache headers allow conditional requests
    assert_not_nil response.headers["Cache-Control"], "Should have Cache-Control header"
  end

  # Stale ETag and Last-Modified behavior tests for Task 2.2
  test "returns 200 for stale If-Modified-Since" do
    habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # Get current Last-Modified
    get habit_entries_month_path(year: 2025, month: 10)
    assert_response :success

    # Update habit data to make timestamp stale
    habit.update!(name: "Evening Exercise")

    # Request with stale If-Modified-Since (from before the update)
    stale_timestamp = 1.hour.ago.httpdate
    get habit_entries_month_path(year: 2025, month: 10), headers: { "If-Modified-Since" => stale_timestamp }
    assert_response :success
    assert_not_empty response.body, "200 response should have body content when data is newer"
  end

  test "Last-Modified changes when habit data changes" do
    habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # First request
    get habit_entries_month_path(year: 2025, month: 10)
    last_modified1 = response.headers["Last-Modified"]

    # Change habit data
    travel 1.minute
    habit.update!(name: "Evening Exercise")

    # Second request after change
    get habit_entries_month_path(year: 2025, month: 10)
    last_modified2 = response.headers["Last-Modified"]

    assert_not_equal last_modified1, last_modified2, "Last-Modified should change when habit data changes"
  ensure
    travel_back
  end

  test "ETag and Last-Modified work together for cache validation" do
    habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # First request to get both headers
    get habit_entries_month_path(year: 2025, month: 10)
    etag = response.headers["ETag"]
    last_modified = response.headers["Last-Modified"]

    # Request with both If-None-Match and If-Modified-Since
    get habit_entries_month_path(year: 2025, month: 10), headers: {
      "If-None-Match" => etag,
      "If-Modified-Since" => last_modified
    }
    assert_response :not_modified
    assert_empty response.body, "304 response should have empty body when both conditions match"
  end

  test "returns 200 when both ETag and Last-Modified are stale" do
    habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # Get initial headers
    get habit_entries_month_path(year: 2025, month: 10)
    old_etag = response.headers["ETag"]
    old_last_modified = response.headers["Last-Modified"]

    # Change data to make both headers stale
    travel 1.minute
    habit.update!(name: "Evening Exercise")

    # Request with stale headers
    get habit_entries_month_path(year: 2025, month: 10), headers: {
      "If-None-Match" => old_etag,
      "If-Modified-Since" => old_last_modified
    }
    assert_response :success
    assert_not_empty response.body, "200 response should have body when data has changed"

    # Verify new headers are different
    assert_not_equal old_etag, response.headers["ETag"], "ETag should be different after data change"
    assert_not_equal old_last_modified, response.headers["Last-Modified"], "Last-Modified should be different after data change"
  ensure
    travel_back
  end

  # HTTP header verification tests for Task 2.5
  test "sets correct ETag format" do
    Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    get habit_entries_month_path(year: 2025, month: 10)
    assert_response :success

    etag = response.headers["ETag"]
    assert_not_nil etag, "ETag header should be present"
    # Rails uses weak ETags (W/"hash") for fresh_when
    assert_match(/\A(W\/)?"[a-f0-9]{32}"\z/, etag, "ETag should be a quoted MD5 hash (may be weak)")
  end

  test "sets correct Last-Modified format" do
    Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    get habit_entries_month_path(year: 2025, month: 10)
    assert_response :success

    last_modified = response.headers["Last-Modified"]
    assert_not_nil last_modified, "Last-Modified header should be present"

    # Parse as HTTP date to verify format
    parsed_time = Time.httpdate(last_modified)
    assert parsed_time.is_a?(Time), "Last-Modified should be valid HTTP date format"
  end

  test "ETag reflects actual data changes" do
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
    etag1 = response.headers["ETag"]

    # Create habit entry
    HabitEntry.create!(habit: habit, day: 1, completed: true)

    # Get new ETag after data change
    get habit_entries_month_path(year: 2025, month: 10)
    etag2 = response.headers["ETag"]

    assert_not_equal etag1, etag2, "ETag should change when habit entries are created"
  end

  test "Last-Modified reflects most recent change" do
    travel_to Time.zone.local(2025, 10, 1, 10, 0, 0)

    habit = Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # Update habit at a specific time
    travel_to Time.zone.local(2025, 10, 1, 11, 0, 0)
    habit.update!(name: "Evening Exercise")

    get habit_entries_month_path(year: 2025, month: 10)
    last_modified = Time.httpdate(response.headers["Last-Modified"])

    # Last-Modified should be close to the update time
    expected_time = Time.zone.local(2025, 10, 1, 11, 0, 0)
    assert_in_delta expected_time.to_i, last_modified.to_i, 60, "Last-Modified should reflect recent update time"
  ensure
    travel_back
  end

  test "headers work correctly for user without habits" do
    # Test with user who has no habits for this month
    get habit_entries_month_path(year: 2025, month: 10)
    assert_response :success

    etag = response.headers["ETag"]
    last_modified = response.headers["Last-Modified"]

    assert_not_nil etag, "ETag should be present even without habits"
    assert_not_nil last_modified, "Last-Modified should be present even without habits"
  end

  test "headers are consistent across multiple requests" do
    Habit.create!(
      user: @user,
      name: "Morning Exercise",
      year: 2025,
      month: 10,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # Make multiple requests without changing data
    get habit_entries_month_path(year: 2025, month: 10)
    etag1 = response.headers["ETag"]
    last_modified1 = response.headers["Last-Modified"]

    get habit_entries_month_path(year: 2025, month: 10)
    etag2 = response.headers["ETag"]
    last_modified2 = response.headers["Last-Modified"]

    get habit_entries_month_path(year: 2025, month: 10)
    etag3 = response.headers["ETag"]
    last_modified3 = response.headers["Last-Modified"]

    assert_equal etag1, etag2, "ETag should be consistent across requests"
    assert_equal etag2, etag3, "ETag should be consistent across requests"
    assert_equal last_modified1, last_modified2, "Last-Modified should be consistent across requests"
    assert_equal last_modified2, last_modified3, "Last-Modified should be consistent across requests"
  end
end
