require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email_address: "test@example.com",
      password: "secure_password123"
    )

    # Create a habit for the current month so user doesn't get redirected to habits setup
    current_date = Date.current
    @user.habits.create!(
      name: "Test Habit",
      month: current_date.month,
      year: current_date.year,
      position: 1,
      active: true,
      check_type: "x_marks"
    )
  end

  test "should get new" do
    get new_session_url
    assert_response :success
    assert_select "form[action=?]", session_path
    assert_select "input[type=email][name=?]", "email_address"
    assert_select "input[type=password][name=?]", "password"
    assert_select "input[type=submit][value=?]", "Sign in"
  end

  test "should create session with valid credentials" do
    post session_url, params: {
      email_address: @user.email_address,
      password: "secure_password123"
    }
    assert_redirected_to root_path

    # Check that the user is now authenticated
    get root_path
    assert_response :success
  end

  test "should not create session with invalid password" do
    post session_url, params: {
      email_address: @user.email_address,
      password: "wrong_password"
    }
    assert_redirected_to new_session_path
  end

  test "should not create session with non-existent email" do
    post session_url, params: {
      email_address: "nonexistent@example.com",
      password: "any_password"
    }
    assert_redirected_to new_session_path
  end

  test "should destroy session" do
    # First sign in
    post session_url, params: {
      email_address: @user.email_address,
      password: "secure_password123"
    }
    assert_redirected_to root_path

    # Then sign out
    delete session_url
    assert_redirected_to new_session_path
  end

  test "should handle case-insensitive email on login" do
    post session_url, params: {
      email_address: "TEST@EXAMPLE.COM",
      password: "secure_password123"
    }
    assert_redirected_to root_path
  end

  test "should handle email with extra spaces on login" do
    post session_url, params: {
      email_address: "  test@example.com  ",
      password: "secure_password123"
    }
    assert_redirected_to root_path
  end
end
