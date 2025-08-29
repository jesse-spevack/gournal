require "test_helper"

class StyleGuideControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Sign in a user for authentication
    @user = users(:one)
    post session_path, params: { email_address: @user.email_address, password: "password" }
  end

  test "style guide index is accessible" do
    get style_guide_path
    assert_response :success
  end

  test "style guide displays checkbox content" do
    get style_guide_path
    assert_response :success
    assert_select ".checkbox-showcase"
  end

  test "style guide displays color palette" do
    get style_guide_path
    assert_response :success
    assert_select ".color-grid"
  end
end
