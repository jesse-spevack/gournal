require "test_helper"

class StyleGuideControllerTest < ActionDispatch::IntegrationTest
  test "style guide index is accessible without authentication" do
    get style_guide_path
    assert_response :success
  end

  test "style guide displays checkbox content without authentication" do
    get style_guide_path
    assert_response :success
    assert_select ".checkbox-showcase"
  end

  test "style guide displays color palette without authentication" do
    get style_guide_path
    assert_response :success
    assert_select ".color-grid"
  end

  test "style guide is accessible when authenticated" do
    @user = users(:one)
    post session_path, params: { email_address: @user.email_address, password: "password" }

    get style_guide_path
    assert_response :success
  end
end
