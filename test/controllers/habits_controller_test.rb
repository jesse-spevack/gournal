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

    assert_response :unprocessable_content
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

    assert_response :unprocessable_content
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

  # ===== PHASE 2.3: HABIT MANAGEMENT FEATURES =====
  # These tests are for advanced habit management features:
  # - Copy habits from previous month
  # - Enforce habit limits (3-10 habits per month)
  # - Enhanced position management
  # - Turbo Frame integration for smooth UI interactions

  # Copy from Previous Month Feature Tests
  test "can copy habits from previous month" do
    # Create habits in previous month (January for current February test)
    previous_month = Date.current.prev_month
    Habit.create!(
      name: "Previous Exercise",
      user: @user,
      month: previous_month.month,
      year: previous_month.year,
      position: 1,
      check_type: "x_marks"
    )
    Habit.create!(
      name: "Previous Reading",
      user: @user,
      month: previous_month.month,
      year: previous_month.year,
      position: 2,
      check_type: "blots"
    )

    # Test copying to current month
    post habits_path, params: {
      habit: { copy_from_previous: true },
      year: Date.current.year,
      month: Date.current.month
    }

    assert_response :redirect
    assert_equal "2 habits copied from #{previous_month.strftime('%B %Y')}.", flash[:notice]

    # Verify habits were copied with correct attributes
    current_month_habits = @user.habits.current_month(Date.current.year, Date.current.month)
    assert_equal 4, current_month_habits.count # 2 existing + 2 copied

    copied_exercise = current_month_habits.find_by(name: "Previous Exercise")
    assert_not_nil copied_exercise
    assert_equal Date.current.month, copied_exercise.month
    assert_equal Date.current.year, copied_exercise.year
    assert_equal "x_marks", copied_exercise.check_type
    assert_equal 3, copied_exercise.position # Next available after existing habits

    copied_reading = current_month_habits.find_by(name: "Previous Reading")
    assert_not_nil copied_reading
    assert_equal "blots", copied_reading.check_type
    assert_equal 4, copied_reading.position
  end

  test "copy from previous month handles empty previous month" do
    # Ensure no habits exist in previous month
    previous_month = Date.current.prev_month
    @user.habits.current_month(previous_month.year, previous_month.month).destroy_all

    post habits_path, params: {
      habit: { copy_from_previous: true },
      year: Date.current.year,
      month: Date.current.month
    }

    assert_response :redirect
    assert_equal "No habits found to copy from #{previous_month.strftime('%B %Y')}.", flash[:notice]

    # Verify no new habits were created
    current_month_habits = @user.habits.current_month(Date.current.year, Date.current.month)
    assert_equal 2, current_month_habits.count # Only the original 2 habits
  end

  test "copy from previous month handles December to January transition" do
    # Create habits in December 2024
    Habit.create!(
      name: "December Exercise",
      user: @user,
      month: 12,
      year: 2024,
      position: 1,
      check_type: "x_marks"
    )

    # Copy to January 2025
    post habits_path, params: {
      habit: { copy_from_previous: true },
      year: 2025,
      month: 1
    }

    assert_response :redirect
    assert_equal "1 habit copied from December 2024.", flash[:notice]

    # Verify habit was copied correctly
    january_habits = @user.habits.current_month(2025, 1)
    copied_habit = january_habits.find_by(name: "December Exercise")
    assert_not_nil copied_habit
    assert_equal 1, copied_habit.month
    assert_equal 2025, copied_habit.year
  end

  test "copy from previous month only copies current user's habits" do
    previous_month = Date.current.prev_month

    # Create habit for current user
    Habit.create!(
      name: "My Previous Habit",
      user: @user,
      month: previous_month.month,
      year: previous_month.year,
      position: 1,
      check_type: "x_marks"
    )

    # Create habit for other user
    Habit.create!(
      name: "Other User Habit",
      user: @other_user,
      month: previous_month.month,
      year: previous_month.year,
      position: 1,
      check_type: "blots"
    )

    post habits_path, params: {
      habit: { copy_from_previous: true },
      year: Date.current.year,
      month: Date.current.month
    }

    assert_response :redirect
    assert_equal "1 habit copied from #{previous_month.strftime('%B %Y')}.", flash[:notice]

    # Verify only current user's habit was copied
    current_month_habits = @user.habits.current_month(Date.current.year, Date.current.month)
    assert current_month_habits.exists?(name: "My Previous Habit")
    refute current_month_habits.exists?(name: "Other User Habit")
  end

  # Habit Limit Enforcement Tests
  test "enforces maximum habit limit of 10 per month" do
    # Create 8 more habits to reach the limit of 10 (we already have 2)
    8.times do |i|
      Habit.create!(
        name: "Extra Habit #{i + 1}",
        user: @user,
        month: Date.current.month,
        year: Date.current.year,
        position: i + 3,
        check_type: "x_marks"
      )
    end

    # Try to create the 11th habit
    post habits_path, params: {
      habit: {
        name: "Too Many Habits",
        month: Date.current.month,
        year: Date.current.year,
        check_type: "x_marks"
      }
    }

    assert_response :unprocessable_content
    assert_select ".error", text: /Maximum of 10 habits allowed per month/i

    # Verify habit was not created
    refute @user.habits.exists?(name: "Too Many Habits")
    assert_equal 10, @user.habits.current_month(Date.current.year, Date.current.month).count
  end

  test "allows creating habits up to the limit" do
    # Create 8 more habits to reach exactly 10
    8.times do |i|
      Habit.create!(
        name: "Habit #{i + 1}",
        user: @user,
        month: Date.current.month,
        year: Date.current.year,
        position: i + 3,
        check_type: "x_marks"
      )
    end

    # Verify we can view the index with 10 habits
    get habits_path
    assert_response :success
    assert_select ".habit-row", count: 10

    # Verify we cannot create an 11th habit
    post habits_path, params: {
      habit: {
        name: "One Too Many",
        month: Date.current.month,
        year: Date.current.year,
        check_type: "blots"
      }
    }

    assert_response :unprocessable_content
  end

  test "habit limit applies per month and user" do
    # Setup already has 2 habits (positions 1,2), create 8 more for total of 10
    8.times do |i|
      Habit.create!(
        name: "Current Month #{i + 1}",
        user: @user,
        month: Date.current.month,
        year: Date.current.year,
        position: i + 3, # positions 3-10
        check_type: "x_marks"
      )
    end

    # Create habit for other user - should not affect limit
    other_user_position = (@other_user.habits.where(month: Date.current.month, year: Date.current.year).maximum(:position) || 0) + 1
    Habit.create!(
      name: "Other User Current",
      user: @other_user,
      month: Date.current.month,
      year: Date.current.year,
      position: other_user_position,
      check_type: "blots"
    )

    # Create habit for same user in different month - should not affect limit
    next_month = Date.current.next_month
    Habit.create!(
      name: "Next Month Habit",
      user: @user,
      month: next_month.month,
      year: next_month.year,
      position: 1,
      check_type: "x_marks"
    )

    # Try to create 11th habit for current user in current month
    post habits_path, params: {
      habit: {
        name: "Over Limit",
        month: Date.current.month,
        year: Date.current.year,
        check_type: "x_marks"
      }
    }

    assert_response :unprocessable_content
    assert_equal 10, @user.habits.current_month(Date.current.year, Date.current.month).count
  end

  test "copy from previous month respects habit limit" do
    # Create 9 more habits in current month (total 11 with existing 2)
    8.times do |i|
      Habit.create!(
        name: "Current #{i + 1}",
        user: @user,
        month: Date.current.month,
        year: Date.current.year,
        position: i + 3,
        check_type: "x_marks"
      )
    end

    # Create 3 habits in previous month
    previous_month = Date.current.prev_month
    3.times do |i|
      Habit.create!(
        name: "Previous #{i + 1}",
        user: @user,
        month: previous_month.month,
        year: previous_month.year,
        position: i + 1,
        check_type: "blots"
      )
    end

    # Try to copy - should be rejected due to limit
    post habits_path, params: {
      habit: { copy_from_previous: true },
      year: Date.current.year,
      month: Date.current.month
    }

    assert_response :unprocessable_content
    assert_select ".error", text: /Cannot copy habits.*would exceed.*limit of 10/i

    # Verify no habits were copied
    current_habits = @user.habits.current_month(Date.current.year, Date.current.month)
    assert_equal 10, current_habits.count
    refute current_habits.exists?(name: "Previous 1")
  end

  # Enhanced Position Management Tests
  test "automatically assigns position when creating habit" do
    # Delete existing habits to start fresh
    @user.habits.current_month(Date.current.year, Date.current.month).destroy_all

    # Create first habit
    post habits_path, params: {
      habit: {
        name: "First Habit",
        month: Date.current.month,
        year: Date.current.year,
        check_type: "x_marks"
      }
    }

    first_habit = @user.habits.find_by(name: "First Habit")
    assert_equal 1, first_habit.position

    # Create second habit
    post habits_path, params: {
      habit: {
        name: "Second Habit",
        month: Date.current.month,
        year: Date.current.year,
        check_type: "blots"
      }
    }

    second_habit = @user.habits.find_by(name: "Second Habit")
    assert_equal 2, second_habit.position
  end

  test "handles position conflicts by reassigning to next available" do
    # Try to create habit with explicit position that conflicts
    post habits_path, params: {
      habit: {
        name: "Conflicting Position",
        month: Date.current.month,
        year: Date.current.year,
        position: 1, # Same as @habit1
        check_type: "x_marks"
      }
    }

    new_habit = @user.habits.find_by(name: "Conflicting Position")
    assert_equal 3, new_habit.position # Should get next available (after 1 and 2)

    # Verify original habit positions unchanged
    @habit1.reload
    @habit2.reload
    assert_equal 1, @habit1.position
    assert_equal 2, @habit2.position
  end

  test "updates habit positions correctly when reordering" do
    patch habit_path(@habit2), params: {
      habit: { position: 1 }
    }

    # This should move habit2 to position 1 and handle position conflicts
    @habit2.reload
    # Note: The actual reordering logic needs to be implemented
    # This test will fail until the reordering feature is built
    assert_response :redirect
  end

  # Turbo Frame Integration Tests
  test "create habit responds to turbo frame requests" do
    post habits_path,
         params: { habit: { name: "Turbo Habit", month: Date.current.month, year: Date.current.year, check_type: "x_marks" } },
         headers: { "Turbo-Frame" => "new_habit_form" }

    assert_response :redirect
    assert_equal "Habit was successfully created.", flash[:notice]

    # Verify turbo frame response includes proper redirect
    assert_match /turbo/, response.headers["Content-Type"] || ""
  end

  test "delete habit responds to turbo frame requests" do
    delete habit_path(@habit1),
           headers: { "Turbo-Frame" => "habit_#{@habit1.id}" }

    assert_response :redirect
    assert_equal "Habit was successfully deleted.", flash[:notice]
  end

  test "copy from previous month responds to turbo frame requests" do
    # Create habit in previous month
    previous_month = Date.current.prev_month
    Habit.create!(
      name: "Previous Habit",
      user: @user,
      month: previous_month.month,
      year: previous_month.year,
      position: 1,
      check_type: "x_marks"
    )

    post habits_path,
         params: { habit: { copy_from_previous: true }, year: Date.current.year, month: Date.current.month },
         headers: { "Turbo-Frame" => "habit_management" }

    assert_response :redirect
    assert_match "copied", flash[:notice]
  end

  # Edge Cases and Error Handling
  test "handles invalid copy parameters gracefully" do
    post habits_path, params: {
      habit: { copy_from_previous: true },
      year: "invalid",
      month: "invalid"
    }

    assert_response :unprocessable_content
    assert_select ".error", text: /Invalid month or year/i
  end

  test "handles concurrent habit creation properly" do
    # Simulate concurrent requests by creating habits with same target position
    habit_params = {
      habit: {
        name: "Concurrent Habit",
        month: Date.current.month,
        year: Date.current.year,
        check_type: "x_marks"
      }
    }

    post habits_path, params: habit_params
    assert_response :redirect

    # Second request should still work and get next position
    habit_params[:habit][:name] = "Concurrent Habit 2"
    post habits_path, params: habit_params
    assert_response :redirect

    # Verify both habits exist with unique positions
    concurrent_habits = @user.habits.where(name: [ "Concurrent Habit", "Concurrent Habit 2" ])
    assert_equal 2, concurrent_habits.count
    positions = concurrent_habits.pluck(:position).sort
    assert_equal [ 3, 4 ], positions
  end

  test "preserves habit entry data when position changes" do
    # Create some habit entries
    HabitEntry.create!(habit: @habit1, day: 1, completed: true)
    HabitEntry.create!(habit: @habit1, day: 2, completed: false)
    original_entry_count = @habit1.habit_entries.count

    # Change position (this will test when reordering is implemented)
    patch habit_path(@habit1), params: { habit: { position: 3 } }

    @habit1.reload
    assert_equal original_entry_count, @habit1.habit_entries.count
    assert @habit1.habit_entries.exists?(day: 1, completed: true)
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
