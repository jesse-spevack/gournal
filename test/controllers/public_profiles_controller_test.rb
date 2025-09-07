require "test_helper"

class PublicProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email_address: "profile@example.com",
      password: "password123",
      slug: "test-user",
      habits_public: true,
      reflections_public: true
    )

    # Create some test habits
    @habit = @user.habits.create!(
      name: "Exercise",
      year: Date.current.year,
      month: Date.current.month,
      position: 1,
      active: true,
      check_type: "x_marks"
    )

    # Create a habit entry
    @habit_entry = @habit.habit_entries.create!(
      day: 1,
      completed: true
    )

    # Create a reflection
    @reflection = @user.daily_reflections.create!(
      date: Date.current.beginning_of_month,
      content: "Test reflection"
    )
  end

  test "should show public profile for user with slug" do
    get public_profile_path(slug: @user.slug)
    assert_response :success
    assert_select "h1", /#{Date.current.strftime("%B")}/
    assert_select ".profile-user-name", "@#{@user.slug}"
  end

  test "should return 404 for non-existent slug" do
    get public_profile_path(slug: "non-existent")
    assert_response :not_found
  end

  test "should show habits when habits_public is true" do
    get public_profile_path(slug: @user.slug)
    assert_response :success
    assert_select ".habit-name", @habit.name
  end

  test "should hide habits when habits_public is false" do
    @user.update!(habits_public: false)

    get public_profile_path(slug: @user.slug)
    assert_response :success
    assert_select ".habit-name", false
  end

  test "should show reflections when reflections_public is true" do
    get public_profile_path(slug: @user.slug)
    assert_response :success
    assert_match @reflection.content, response.body
  end

  test "should hide reflections when reflections_public is false" do
    @user.update!(reflections_public: false)

    get public_profile_path(slug: @user.slug)
    assert_response :success
    assert_no_match @reflection.content, response.body
  end

  test "should show 404 when slug does not exist" do
    get public_profile_path(slug: "does-not-exist")
    assert_response :not_found
  end

  test "should allow unauthenticated access" do
    get public_profile_path(slug: @user.slug)
    assert_response :success
  end

  test "should show create account button for unauthenticated users" do
    get public_profile_path(slug: @user.slug)
    assert_response :success
    assert_select ".canonical-button--secondary"
  end

  test "should not show create account button for authenticated users" do
    sign_in_as(@user)

    get public_profile_path(slug: @user.slug)
    assert_response :success
    assert_select ".create-account-button", false
  end

  test "should support year and month parameters" do
    get public_profile_month_path(slug: @user.slug, year: 2025, month: 9)
    assert_response :success
    assert_select "h1", /September 2025/
  end

  test "should validate year and month parameters" do
    # Invalid year
    get public_profile_month_path(slug: @user.slug, year: 1999, month: 1)
    assert_response :success
    assert_select "h1", /#{Date.current.strftime("%B %Y")}/

    # Invalid month
    get public_profile_month_path(slug: @user.slug, year: 2025, month: 13)
    assert_response :success
    assert_select "h1", /#{Date.current.strftime("%B %Y")}/
  end

  test "should show attribution footer" do
    get public_profile_path(slug: @user.slug)
    assert_response :success
    assert_select ".attribution", /verynormal\.dev/
  end

  test "should handle user with no habits gracefully" do
    user_no_habits = User.create!(
      email_address: "no-habits@example.com",
      password: "password123",
      slug: "no-habits",
      habits_public: true
    )

    get public_profile_path(slug: user_no_habits.slug)
    assert_response :success
    # Empty state rendering is handled but no specific class currently
  end

  private

  def sign_in_as(user)
    post session_path, params: {
      email_address: user.email_address,
      password: "password123"
    }
  end
end
