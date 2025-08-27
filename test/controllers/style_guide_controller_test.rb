require "test_helper"

class StyleGuideControllerTest < ActionDispatch::IntegrationTest
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
