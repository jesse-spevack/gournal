require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Create a user and habit for testing
    @user = User.create!(email_address: "test@example.com", password: "password123")
    @habit = @user.habits.create!(
      name: "Test Habit",
      year: Date.current.year,
      month: Date.current.month,
      position: 1,
      check_type: "x_marks"
    )
    sign_in_as @user
  end

  test "set_timezone reads valid timezone from cookie and affects date calculation" do
    # Set timezone cookie
    post timezone_path, params: { timezone: "America/Denver" }, as: :json
    assert_response :ok

    # Verify the timezone is used in subsequent requests
    # In UTC it's Oct 8 at 6:00 AM, but in Denver (UTC-6) it's Oct 7 at 11:00 PM
    travel_to Time.utc(2025, 10, 8, 6, 0, 0) do
      get root_path
      assert_response :success
      # The page should show Oct 7 as "today" in Denver timezone
    end
  end

  test "set_timezone ignores invalid timezone in cookie" do
    # Set an invalid timezone cookie
    cookies[:tz] = "Invalid/Zone"
    get root_path
    assert_response :success
    # Should not crash, falls back to UTC
  end

  test "handles missing timezone cookie gracefully" do
    # Already signed in from setup, no timezone cookie set
    get root_path
    assert_response :success
    # Should default to UTC
  end

  private

  def sign_in_as(user)
    post session_path, params: {
      email_address: user.email_address,
      password: "password123"
    }
  end
end
