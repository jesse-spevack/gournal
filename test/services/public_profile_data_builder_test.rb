require "test_helper"

class PublicProfileDataBuilderTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email_address: "test@example.com",
      password: "password123",
      slug: "test-user"
    )

    @year = Date.current.year
    @month = Date.current.month

    # Create test habits
    @public_habit = @user.habits.create!(
      name: "Public Habit",
      year: @year,
      month: @month,
      position: 1,
      active: true,
      check_type: "x_marks"
    )

    @private_habit = @user.habits.create!(
      name: "Private Habit",
      year: @year,
      month: @month,
      position: 2,
      active: true,
      check_type: "blots"
    )

    # Create habit entries
    @public_habit.habit_entries.create!(day: 1, completed: true)
    @private_habit.habit_entries.create!(day: 2, completed: true)

    # Create reflections
    @reflection = @user.daily_reflections.create!(
      date: Date.new(@year, @month, 3),
      content: "Test reflection"
    )
  end

  test "should return empty data when user has no public profile" do
    @user.update!(slug: nil)

    data = PublicProfileDataBuilder.call(user: @user, year: @year, month: @month)

    assert data.empty?
    assert_equal 0, data.habits.count
    assert_empty data.habit_entries_lookup
    assert_empty data.reflections_lookup
  end

  test "should include habits when habits_public is true" do
    @user.update!(habits_public: true, reflections_public: false)

    data = PublicProfileDataBuilder.call(user: @user, year: @year, month: @month)

    assert_not data.empty?
    assert_equal 2, data.habits.count
    assert_includes data.habits, @public_habit
    assert_includes data.habits, @private_habit
    assert_not_empty data.habit_entries_lookup
  end

  test "should exclude habits when habits_public is false" do
    @user.update!(habits_public: false, reflections_public: true)

    data = PublicProfileDataBuilder.call(user: @user, year: @year, month: @month)

    assert_equal 0, data.habits.count
    assert_empty data.habit_entries_lookup
  end

  test "should include reflections when reflections_public is true" do
    @user.update!(habits_public: false, reflections_public: true)

    data = PublicProfileDataBuilder.call(user: @user, year: @year, month: @month)

    assert_not_empty data.reflections_lookup
    assert_equal @reflection, data.reflection_for(3)
  end

  test "should exclude reflections when reflections_public is false" do
    @user.update!(habits_public: true, reflections_public: false)

    data = PublicProfileDataBuilder.call(user: @user, year: @year, month: @month)

    assert_empty data.reflections_lookup
    assert_nil data.reflection_for(3)
  end

  test "should respect both privacy settings" do
    @user.update!(habits_public: true, reflections_public: true)

    data = PublicProfileDataBuilder.call(user: @user, year: @year, month: @month)

    assert_not data.empty?
    assert_equal 2, data.habits.count
    assert_not_empty data.habit_entries_lookup
    assert_not_empty data.reflections_lookup
  end

  test "should filter by specified year and month" do
    # Create habit in different month
    other_habit = @user.habits.create!(
      name: "Other Month",
      year: @year,
      month: (@month % 12) + 1,
      position: 1,
      active: true,
      check_type: "x_marks"
    )

    @user.update!(habits_public: true)

    data = PublicProfileDataBuilder.call(user: @user, year: @year, month: @month)

    assert_not_includes data.habits, other_habit
  end

  test "should only include active habits" do
    @public_habit.update!(active: false)
    @user.update!(habits_public: true)

    data = PublicProfileDataBuilder.call(user: @user, year: @year, month: @month)

    assert_not_includes data.habits, @public_habit
    assert_includes data.habits, @private_habit
  end

  test "should raise error for nil user" do
    assert_raises(ArgumentError) do
      PublicProfileDataBuilder.call(user: nil, year: @year, month: @month)
    end
  end

  test "should set correct month metadata" do
    data = PublicProfileDataBuilder.call(user: @user, year: 2025, month: 9)

    assert_equal "September", data.month_name
    assert_equal 30, data.days_in_month
    assert_equal 2025, data.year
    assert_equal 9, data.month
  end
end
