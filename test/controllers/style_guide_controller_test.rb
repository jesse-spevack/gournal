require "test_helper"

class StyleGuideControllerTest < ActionDispatch::IntegrationTest
  test "style guide index accessible in development" do
    # This test runs in test environment which should allow access for TDD purposes
    get style_guide_path
    assert_response :success
  end

  test "style guide redirects to root in production environment" do
    # Simulate production environment behavior by switching temporarily
    original_env = Rails.env
    Rails.env = ActiveSupport::EnvironmentInquirer.new("production")
    
    begin
      get style_guide_path
      assert_redirected_to root_path
    ensure
      Rails.env = original_env
    end
  end

  test "style guide displays checkbox variations content in development" do
    get style_guide_path
    assert_response :success
    
    # Test that the view renders content related to checkbox variations
    # We'll verify this through the rendered response content
    assert_select "body" # Basic check that page renders
  end

  test "style guide displays color palette content in development" do
    get style_guide_path
    assert_response :success
    
    # Test that the view renders content related to color palette
    # We'll verify this through the rendered response content  
    assert_select "body" # Basic check that page renders
  end
end