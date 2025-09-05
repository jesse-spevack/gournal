require "test_helper"

class DailyReflectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @daily_reflection = DailyReflection.create!(
      user: @user,
      date: Date.new(2025, 9, 1),
      content: "Test reflection"
    )

    # Sign in the user
    post session_url, params: {
      email_address: @user.email_address,
      password: "password"  # Fixture password
    }
  end

  test "create should create new reflection with valid params" do
    reflection_params = {
      daily_reflection: {
        content: "New reflection content",
        date: Date.new(2025, 9, 15)
      }
    }

    assert_difference "DailyReflection.count", 1 do
      post daily_reflections_path, params: reflection_params, as: :json
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "success", json_response["status"]
    assert_not_nil json_response["id"]
    assert_equal "New reflection content", json_response["content"]
  end

  test "create should return error for invalid params" do
    reflection_params = {
      daily_reflection: {
        content: "Content without date"
        # Missing required date
      }
    }

    assert_no_difference "DailyReflection.count" do
      post daily_reflections_path, params: reflection_params, as: :json
    end

    assert_response :unprocessable_content
    json_response = JSON.parse(response.body)
    assert_equal "error", json_response["status"]
    assert_includes json_response["errors"], "Date can't be blank"
  end


  test "update should update existing reflection" do
    patch daily_reflection_path(@daily_reflection.id),
          params: { daily_reflection: { content: "Updated content" } },
          as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "success", json_response["status"]
    assert_equal "Updated content", json_response["content"]

    @daily_reflection.reload
    assert_equal "Updated content", @daily_reflection.content
  end

  test "update should return error for invalid params" do
    patch daily_reflection_path(@daily_reflection.id),
          params: { daily_reflection: { date: nil } },
          as: :json

    assert_response :unprocessable_content
    json_response = JSON.parse(response.body)
    assert_equal "error", json_response["status"]
    assert_includes json_response["errors"], "Date can't be blank"
  end

  test "update should handle record not found" do
    patch daily_reflection_path(99999),
          params: { daily_reflection: { content: "Content" } },
          as: :json

    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "error", json_response["status"]
    assert_equal "Reflection not found", json_response["message"]
  end
end
