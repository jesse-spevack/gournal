require "test_helper"

class SettingsProfileTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email_address: "settings@example.com",
      password: "password123",
      onboarding_state: :completed
    )
    sign_in_as(@user)
  end

  test "should update slug successfully" do
    patch settings_path, params: {
      user: {
        slug: "new-slug",
        habits_public: "false",
        reflections_public: "false"
      }
    }

    assert_redirected_to settings_path
    assert_equal "Profile settings updated successfully", flash[:notice]

    @user.reload
    assert_equal "new-slug", @user.slug
  end

  test "should update privacy settings" do
    patch settings_path, params: {
      user: {
        slug: @user.slug,
        habits_public: "true",
        reflections_public: "true"
      }
    }

    assert_redirected_to settings_path

    @user.reload
    assert @user.habits_public?
    assert @user.reflections_public?
  end

  test "should handle invalid slug format" do
    patch settings_path, params: {
      user: {
        slug: "Invalid Slug!",
        habits_public: "false",
        reflections_public: "false"
      }
    }

    assert_response :unprocessable_content
    assert_select ".field-error"

    @user.reload
    assert_not_equal "Invalid Slug!", @user.slug
  end

  test "should handle duplicate slug" do
    other_user = User.create!(
      email_address: "other@example.com",
      password: "password123",
      slug: "taken-slug"
    )

    patch settings_path, params: {
      user: {
        slug: "taken-slug",
        habits_public: "false",
        reflections_public: "false"
      }
    }

    assert_response :unprocessable_content

    @user.reload
    assert_not_equal "taken-slug", @user.slug
  end

  test "should allow clearing slug" do
    @user.update!(slug: "existing-slug")

    patch settings_path, params: {
      user: {
        slug: "",
        habits_public: "false",
        reflections_public: "false"
      }
    }

    assert_redirected_to settings_path

    @user.reload
    assert_nil @user.slug
  end

  test "should require authentication" do
    delete session_path # Sign out

    patch settings_path, params: {
      user: {
        slug: "test",
        habits_public: "false",
        reflections_public: "false"
      }
    }

    assert_redirected_to new_session_path
  end

  private

  def sign_in_as(user)
    post session_path, params: {
      email_address: user.email_address,
      password: "password123"
    }
  end
end
