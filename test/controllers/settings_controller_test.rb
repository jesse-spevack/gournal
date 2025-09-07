require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email_address: "test@example.com",
      password: "secure_password123"
    )
  end

  test "should redirect to login when not authenticated" do
    get settings_path
    assert_redirected_to new_session_path
  end

  test "should render settings page when authenticated" do
    # First sign in
    post session_url, params: {
      email_address: @user.email_address,
      password: "secure_password123"
    }
    assert_redirected_to root_path

    # Then access settings page
    get settings_path
    assert_response :success
    assert_select "h1", text: "Settings"
  end

  test "should show only two sections when user has no habits" do
    # Sign in
    post session_url, params: {
      email_address: @user.email_address,
      password: "secure_password123"
    }

    get settings_path
    assert_response :success

    # Check for the two sections when no habits exist
    assert_select ".settings-section.habits-management", count: 1
    assert_select ".settings-section.profile-sharing", count: 1

    # Check section titles
    assert_select "h2.settings-section-title", text: "Manage habits"
    assert_select "h2.settings-section-title", text: "Profile sharing"

    # Month setup section should be hidden when user has no habits
    assert_select ".settings-section.month-setup", count: 0
  end

  test "should show all three sections when user has habits" do
    # Create a habit for the current month
    current_date = Date.current
    Habit.create!(
      name: "Test Habit",
      user: @user,
      year: current_date.year,
      month: current_date.month,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # Sign in
    post session_url, params: {
      email_address: @user.email_address,
      password: "secure_password123"
    }

    get settings_path
    assert_response :success

    # Check for all three sections when habits exist
    assert_select ".settings-section.habits-management", count: 1
    assert_select ".settings-section.month-setup", count: 1
    assert_select ".settings-section.profile-sharing", count: 1

    # Check section titles
    assert_select "h2.settings-section-title", text: "Manage habits"
    assert_select "h2.settings-section-title", text: "Profile sharing"
  end

  test "should hide back button when user has no habits" do
    # Sign in
    post session_url, params: {
      email_address: @user.email_address,
      password: "secure_password123"
    }

    get settings_path
    assert_response :success

    # Back button should be hidden when user has no habits
    assert_select "a[href='#{root_path}'].settings-link", count: 0
  end

  test "should show back button when user has habits" do
    # Create a habit for the current month
    current_date = Date.current
    Habit.create!(
      name: "Test Habit",
      user: @user,
      year: current_date.year,
      month: current_date.month,
      position: 1,
      active: true,
      check_type: :x_marks
    )

    # Sign in
    post session_url, params: {
      email_address: @user.email_address,
      password: "secure_password123"
    }

    get settings_path
    assert_response :success

    # Back button should be visible when user has habits
    assert_select "a[href='#{root_path}'].settings-link", text: "<"
  end

  test "should set return_to_after_authenticating when redirecting" do
    get settings_path
    assert_redirected_to new_session_path

    # Check that the session has the return URL stored
    assert_equal settings_url, session[:return_to_after_authenticating]
  end
end
