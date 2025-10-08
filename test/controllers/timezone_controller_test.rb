require "test_helper"

class TimezoneControllerTest < ActionDispatch::IntegrationTest
  test "stores valid timezone in cookie" do
    post timezone_path, params: { timezone: "America/Denver" }, as: :json

    assert_response :ok
    assert_equal "America/Denver", cookies[:tz]
  end

  test "rejects invalid timezone" do
    post timezone_path, params: { timezone: "Invalid/Zone" }, as: :json

    assert_response :unprocessable_entity
  end

  test "rejects empty timezone" do
    post timezone_path, params: { timezone: "" }, as: :json

    assert_response :unprocessable_entity
  end

  test "rejects nil timezone" do
    post timezone_path, params: { timezone: nil }, as: :json

    assert_response :unprocessable_entity
  end

  test "rejects timezone with null bytes" do
    post timezone_path, params: { timezone: "America/Denver\x00" }, as: :json

    assert_response :unprocessable_entity
  end

  test "rejects extremely long timezone string" do
    post timezone_path, params: { timezone: "A" * 1000 }, as: :json

    assert_response :unprocessable_entity
  end
end
