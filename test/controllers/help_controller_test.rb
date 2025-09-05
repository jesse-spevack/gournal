require "test_helper"

class HelpControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email_address: "test@example.com",
      password: "secure_password123"
    )
  end

  test "should redirect manage_habits to login when not authenticated" do
    get help_manage_habits_path
    assert_redirected_to new_session_path
  end

  test "should redirect next_month_setup to login when not authenticated" do
    get help_next_month_setup_path
    assert_redirected_to new_session_path
  end

  test "should render manage_habits page when authenticated" do
    # Sign in
    post session_url, params: {
      email_address: @user.email_address,
      password: "secure_password123"
    }

    get help_manage_habits_path
    assert_response :success
    assert_select "h1", text: "Habit Management Help"
    assert_select ".help-section", minimum: 4
    assert_select "a[href='#{settings_path}'].settings-link", text: "<"
  end

  test "should render next_month_setup page when authenticated" do
    # Sign in
    post session_url, params: {
      email_address: @user.email_address,
      password: "secure_password123"
    }

    get help_next_month_setup_path
    assert_response :success
    assert_select "h1", text: "Next Month Setup Help"
    assert_select ".help-section", minimum: 4
    assert_select "a[href='#{settings_path}'].settings-link", text: "<"
  end

  test "should set return_to_after_authenticating when redirecting manage_habits" do
    get help_manage_habits_path
    assert_redirected_to new_session_path
    assert_equal help_manage_habits_url, session[:return_to_after_authenticating]
  end

  test "should set return_to_after_authenticating when redirecting next_month_setup" do
    get help_next_month_setup_path
    assert_redirected_to new_session_path
    assert_equal help_next_month_setup_url, session[:return_to_after_authenticating]
  end
end
