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

  test "should show all three settings sections when authenticated" do
    # Sign in
    post session_url, params: {
      email_address: @user.email_address,
      password: "secure_password123"
    }

    get settings_path
    assert_response :success

    # Check for the three main sections
    assert_select ".settings-section.habits-management", count: 1
    assert_select ".settings-section.profile-sharing", count: 1

    # Check section titles
    assert_select "h2.settings-section-title", text: "Manage habits"
    assert_select "h2.settings-section-title", text: "Profile & Sharing"

    # Month setup section should be visible since user has no habits in next month yet
    assert_select ".settings-section.month-setup", count: 1
    # Check for dynamic month setup title (should contain "Set up")
    assert_select "h2.settings-section-title", text: /Set up \w+ \d{4}/
  end

  test "should show back button when authenticated" do
    # Sign in
    post session_url, params: {
      email_address: @user.email_address,
      password: "secure_password123"
    }

    get settings_path
    assert_response :success

    # Check for back button
    assert_select "a[href='#{root_path}'].settings-link", text: "<"
  end

  test "should set return_to_after_authenticating when redirecting" do
    get settings_path
    assert_redirected_to new_session_path

    # Check that the session has the return URL stored
    assert_equal settings_url, session[:return_to_after_authenticating]
  end

  test "should render help page when authenticated" do
    # Sign in
    post session_url, params: {
      email_address: @user.email_address,
      password: "secure_password123"
    }

    get settings_help_path
    assert_response :success
    assert_select "h1", text: "Habit Management Help"
    assert_select ".help-section", minimum: 4
    assert_select "a[href='#{settings_path}'].settings-link", text: "<"
  end

  test "should redirect help page to login when not authenticated" do
    get settings_help_path
    assert_redirected_to new_session_path
  end
end
