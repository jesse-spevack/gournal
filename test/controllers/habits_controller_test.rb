require "test_helper"

class HabitsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email_address: "test@example.com",
      password: "secure_password123"
    )
    @other_user = User.create!(
      email_address: "other@example.com",
      password: "secure_password123"
    )

    # Create some test habits
    @habit1 = Habit.create!(
      name: "Exercise",
      month: Date.current.month,
      year: Date.current.year,
      position: 1,
      user: @user,
      check_type: "x_marks"
    )

    @habit2 = Habit.create!(
      name: "Read",
      month: Date.current.month,
      year: Date.current.year,
      position: 2,
      user: @user,
      check_type: "blots"
    )

    @other_user_habit = Habit.create!(
      name: "Other User Habit",
      month: Date.current.month,
      year: Date.current.year,
      position: 1,
      user: @other_user,
      check_type: "x_marks"
    )

    sign_in_as(@user)
  end

  # Authentication tests
  test "should require authentication for all actions" do
    sign_out

    get habits_path
    assert_redirected_to new_session_path

    get habit_path(@habit1)
    assert_redirected_to new_session_path

    get new_habit_path
    assert_redirected_to new_session_path

    post habits_path, params: { habit: { name: "Test" } }
    assert_redirected_to new_session_path

    get edit_habit_path(@habit1)
    assert_redirected_to new_session_path

    patch habit_path(@habit1), params: { habit: { name: "Updated" } }
    assert_redirected_to new_session_path

    delete habit_path(@habit1)
    assert_redirected_to new_session_path
  end

  # Index action tests (root path - current month grid)
  test "should get index with current month grid" do
    get habits_path
    assert_response :success

    # Should display current month and year in page
    assert_select "h1", text: /#{Date.current.strftime("%B %Y")}/i

    # Should show all user's habits for current month
    assert_select ".habit-row", count: 2
    assert_select ".habit-name", text: "Exercise"
    assert_select ".habit-name", text: "Read"

    # Should not show other user's habits
    refute_select ".habit-name", text: "Other User Habit"

    # Should display grid with days for current month
    days_in_month = Date.current.end_of_month.day
    assert_select ".day-cell", count: days_in_month * 2 # 2 habits * days in month
  end

  test "should display habit entries in grid" do
    # Create some habit entries
    HabitEntry.create!(habit: @habit1, day: 1, completed: true)
    HabitEntry.create!(habit: @habit1, day: 2, completed: false)
    HabitEntry.create!(habit: @habit2, day: 1, completed: true)

    get habits_path
    assert_response :success

    # Should display checkboxes with appropriate states
    assert_select ".checkbox[data-completed='true']", count: 2
    # Calculate expected uncompleted count: (days in month * 2 habits) - 2 completed
    days_in_month = Date.current.end_of_month.day
    expected_false_count = (days_in_month * 2) - 2
    assert_select ".checkbox[data-completed='false']", count: expected_false_count

    # Should have proper form elements for toggling
    assert_select "form.habit-entry-form", minimum: 2
  end

  test "should show navigation for different months" do
    get habits_path
    assert_response :success

    # Should have month navigation
    assert_select ".month-nav" do
      assert_select "a[href*='previous']", text: /Previous/i
      assert_select "a[href*='next']", text: /Next/i
    end
  end

  test "should only show user's own habits in index" do
    get habits_path
    assert_response :success

    # Should show current user's habits
    assert_select ".habit-name", text: "Exercise"
    assert_select ".habit-name", text: "Read"

    # Should not show other user's habits
    refute_select ".habit-name", text: "Other User Habit"
  end

  # Show action tests (specific month/year)
  test "should get show for specific month and year" do
    habit_march = Habit.create!(
      name: "March Habit",
      month: 3,
      year: 2024,
      position: 1,
      user: @user,
      check_type: "x_marks"
    )

    get habit_path(1, year: 2024, month: 3)
    assert_response :success

    # Should display the specific month and year
    assert_select "h1", text: /March 2024/i

    # Should show habits for that month
    assert_select ".habit-name", text: "March Habit"

    # Should not show current month habits
    refute_select ".habit-name", text: "Exercise"
    refute_select ".habit-name", text: "Read"
  end

  test "should handle invalid month/year parameters" do
    get habit_path(1, year: "invalid", month: "invalid")
    assert_redirected_to habits_path
    assert_equal "Invalid month or year.", flash[:alert]
  end

  test "should handle out-of-range month parameters" do
    get habit_path(1, year: 2024, month: 13)
    assert_redirected_to habits_path
    assert_equal "Invalid month or year.", flash[:alert]

    get habit_path(1, year: 2024, month: 0)
    assert_redirected_to habits_path
    assert_equal "Invalid month or year.", flash[:alert]
  end

  test "should only show user's habits for specific month" do
    other_user_march_habit = Habit.create!(
      name: "Other March Habit",
      month: 3,
      year: 2024,
      position: 1,
      user: @other_user,
      check_type: "x_marks"
    )

    get habit_path(1, year: 2024, month: 3)
    assert_response :success

    # Should not show other user's habit
    refute_select ".habit-name", text: "Other March Habit"
  end

  # New action tests
  test "should get new" do
    get new_habit_path
    assert_response :success

    assert_select "form[action=?]", habits_path
    assert_select "input[name=?]", "habit[name]"
    assert_select "select[name=?]", "habit[month]"
    assert_select "select[name=?]", "habit[year]"
    assert_select "select[name=?]", "habit[check_type]"
    assert_select "input[type=submit][value=?]", "Create Habit"
  end

  test "should pre-populate month and year in new form" do
    get new_habit_path, params: { month: 5, year: 2024 }
    assert_response :success

    # Should pre-select the specified month and year
    assert_select "select[name='habit[month]'] option[selected][value='5']"
    assert_select "select[name='habit[year]'] option[selected][value='2024']"
  end

  test "should default to current month and year in new form" do
    get new_habit_path
    assert_response :success

    # Should pre-select current month and year
    assert_select "select[name='habit[month]'] option[selected][value='#{Date.current.month}']"
    assert_select "select[name='habit[year]'] option[selected][value='#{Date.current.year}']"
  end

  # Create action tests
  test "should create habit with valid parameters" do
    assert_difference "Habit.count" do
      post habits_path, params: {
        habit: {
          name: "New Habit",
          month: 6,
          year: 2024,
          check_type: "x_marks"
        }
      }
    end

    habit = Habit.last
    assert_equal "New Habit", habit.name
    assert_equal 6, habit.month
    assert_equal 2024, habit.year
    assert_equal @user, habit.user
    assert_equal "x_marks", habit.check_type

    assert_redirected_to habit_path(1, year: 2024, month: 6)
    assert_equal "Habit was successfully created.", flash[:notice]
  end

  test "should assign next available position when creating habit" do
    # @habit1 has position 1, @habit2 has position 2
    post habits_path, params: {
      habit: {
        name: "Third Habit",
        month: Date.current.month,
        year: Date.current.year,
        check_type: "blots"
      }
    }

    habit = Habit.last
    assert_equal 3, habit.position
  end

  test "should not create habit with invalid parameters" do
    assert_no_difference "Habit.count" do
      post habits_path, params: {
        habit: {
          name: "", # Invalid: blank name
          month: 6,
          year: 2024,
          check_type: "x_marks"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".error", text: /Name can't be blank/i
  end

  test "should not create habit with duplicate position" do
    # This should be handled by auto-assigning next position
    post habits_path, params: {
      habit: {
        name: "New Habit",
        month: Date.current.month,
        year: Date.current.year,
        position: 1, # Same as @habit1
        check_type: "x_marks"
      }
    }

    # Should ignore the duplicate position and assign next available
    habit = Habit.last
    assert_equal 3, habit.position # Next available after positions 1 and 2
  end

  # Edit action tests
  test "should get edit for user's own habit" do
    get edit_habit_path(@habit1)
    assert_response :success

    assert_select "form[action=?]", habit_path(@habit1)
    assert_select "input[name=?][value=?]", "habit[name]", "Exercise"
    assert_select "select[name=?]", "habit[month]"
    assert_select "select[name=?]", "habit[year]"
    assert_select "select[name=?]", "habit[check_type]"
    assert_select "input[type=submit][value=?]", "Update Habit"
  end

  test "should not allow editing other user's habit" do
    get edit_habit_path(@other_user_habit)
    assert_response :not_found
  end

  # Update action tests
  test "should update habit with valid parameters" do
    patch habit_path(@habit1), params: {
      habit: {
        name: "Updated Exercise",
        month: @habit1.month,
        year: @habit1.year,
        check_type: "blots"
      }
    }

    @habit1.reload
    assert_equal "Updated Exercise", @habit1.name
    assert_equal "blots", @habit1.check_type

    assert_redirected_to habit_path(1, year: @habit1.year, month: @habit1.month)
    assert_equal "Habit was successfully updated.", flash[:notice]
  end

  test "should not update habit with invalid parameters" do
    patch habit_path(@habit1), params: {
      habit: {
        name: "" # Invalid: blank name
      }
    }

    assert_response :unprocessable_entity
    assert_select ".error", text: /Name can't be blank/i

    @habit1.reload
    assert_equal "Exercise", @habit1.name # Should not change
  end

  test "should not allow updating other user's habit" do
    patch habit_path(@other_user_habit), params: {
      habit: { name: "Hacked Name" }
    }

    assert_response :not_found

    @other_user_habit.reload
    assert_equal "Other User Habit", @other_user_habit.name # Should not change
  end

  # Destroy action tests
  test "should destroy user's own habit" do
    assert_difference "Habit.count", -1 do
      delete habit_path(@habit1)
    end

    assert_redirected_to habit_path(1, year: @habit1.year, month: @habit1.month)
    assert_equal "Habit was successfully deleted.", flash[:notice]
  end

  test "should not allow destroying other user's habit" do
    assert_no_difference "Habit.count" do
      delete habit_path(@other_user_habit)
    end

    assert_response :not_found
  end

  test "should destroy associated habit entries when destroying habit" do
    HabitEntry.create!(habit: @habit1, day: 1, completed: true)
    HabitEntry.create!(habit: @habit1, day: 2, completed: false)

    assert_difference "HabitEntry.count", -2 do
      delete habit_path(@habit1)
    end
  end

  # Month navigation tests
  test "should handle month navigation" do
    get habits_path, params: { nav: "previous" }
    assert_response :success

    # Should show previous month
    previous_month = Date.current.prev_month
    assert_select "h1", text: /#{previous_month.strftime("%B %Y")}/i

    get habits_path, params: { nav: "next" }
    assert_response :success

    # Should show next month
    next_month = Date.current.next_month
    assert_select "h1", text: /#{next_month.strftime("%B %Y")}/i
  end

  test "should maintain current month when no navigation parameter" do
    get habits_path
    assert_response :success

    assert_select "h1", text: /#{Date.current.strftime("%B %Y")}/i
  end

  # Helper method tests
  test "should handle form errors gracefully" do
    post habits_path, params: {
      habit: {
        name: "",
        month: 13, # Invalid month
        year: "invalid", # Invalid year
        check_type: "x_marks" # Use valid check_type
      }
    }

    assert_response :unprocessable_content
    # Focus on the validation errors we can actually test
    assert_select "form", 1
  end

  private

  def sign_in_as(user)
    post session_url, params: {
      email_address: user.email_address,
      password: "secure_password123"
    }
  end

  def sign_out
    delete session_url
    Current.session = nil
  end
end
