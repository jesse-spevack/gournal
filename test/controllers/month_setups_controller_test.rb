require "test_helper"

class MonthSetupsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email_address: "test@example.com",
      password: "secure_password123"
    )

    # Sign in user
    post session_url, params: {
      email_address: @user.email_address,
      password: "secure_password123"
    }
  end

  test "should redirect to login when not authenticated" do
    delete session_url

    post month_setups_path, params: {
      strategy: "copy",
      target_year: 2025,
      target_month: 10
    }

    assert_redirected_to new_session_path
  end

  test "should copy habits and redirect to target month tracker" do
    # Target is next month; service copies from the month before target (i.e. current month)
    current_date = Date.current
    target_date = current_date.next_month
    target_year = target_date.year
    target_month = target_date.month

    # Create habits in the current month (source for copy)
    habit1 = @user.habits.create!(
      name: "Exercise",
      year: current_date.year,
      month: current_date.month,
      position: 1,
      active: true,
      check_type: "x_marks"
    )
    habit2 = @user.habits.create!(
      name: "Read",
      year: current_date.year,
      month: current_date.month,
      position: 2,
      active: true,
      check_type: "x_marks"
    )

    post month_setups_path, params: {
      strategy: "copy",
      target_year: target_year,
      target_month: target_month
    }

    assert_redirected_to habit_entries_path(year: target_year, month: target_month)

    # Verify habits were copied
    copied_habits = @user.habits.where(year: target_year, month: target_month, active: true)
    assert_equal 2, copied_habits.count
    assert copied_habits.exists?(name: "Exercise")
    assert copied_habits.exists?(name: "Read")
  end

  test "should redirect to habits new page for fresh start" do
    target_year = 2025
    target_month = 10

    post month_setups_path, params: {
      strategy: "fresh",
      target_year: target_year,
      target_month: target_month
    }

    expected_path = new_habit_path(year_month: "#{target_year}-#{target_month.to_s.rjust(2, '0')}")
    assert_redirected_to expected_path
  end

  test "should redirect to settings for invalid strategy" do
    post month_setups_path, params: {
      strategy: "invalid",
      target_year: 2025,
      target_month: 10
    }

    assert_redirected_to settings_path
  end

  test "should redirect to settings when no strategy provided" do
    post month_setups_path, params: {
      target_year: 2025,
      target_month: 10
    }

    assert_redirected_to settings_path
  end
end
