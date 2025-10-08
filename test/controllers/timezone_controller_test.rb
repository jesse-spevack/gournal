require "test_helper"

class TimezoneControllerTest < ActionDispatch::IntegrationTest
  test "stores valid timezone in session and cookie" do
    post timezone_path, params: { timezone: "America/Denver" }, as: :json

    assert_response :ok
    assert_equal "America/Denver", session[:user_timezone]
    assert_equal "America/Denver", cookies[:tz]
  end

  test "rejects invalid timezone" do
    post timezone_path, params: { timezone: "Invalid/Zone" }, as: :json

    assert_response :unprocessable_entity
  end

  test "stores timezone in session for future requests" do
    post timezone_path, params: { timezone: "America/Denver" }, as: :json

    assert_equal "America/Denver", session[:user_timezone]
  end
end
