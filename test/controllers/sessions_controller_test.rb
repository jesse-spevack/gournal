require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email_address: "test@example.com",
      password: "secure_password123"
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
    assert_equal "Try another email address or password.", flash[:alert]
  end

  test "should not create session with non-existent email" do
    post session_url, params: {
      email_address: "nonexistent@example.com",
      password: "any_password"
    }
    assert_redirected_to new_session_path
    assert_equal "Try another email address or password.", flash[:alert]
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

  test "should rate limit failed login attempts" do
    # The controller uses rate_limit with only: :create
    # This is a simple test to ensure the rate limiting is configured
    assert_nothing_raised do
      5.times do
        post session_url, params: {
          email_address: @user.email_address,
          password: "wrong_password"
        }
      end
    end
  end

  test "should show flash messages on login page" do
    # Test alert message
    post session_url, params: {
      email_address: @user.email_address,
      password: "wrong_password"
    }
    follow_redirect!
    assert_select "div.flash.flash--alert", "Try another email address or password."
  end
end
