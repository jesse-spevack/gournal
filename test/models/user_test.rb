require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user_attributes = {
      email_address: "test@example.com",
      password: "secure_password123"
    }
  end

  # Association tests
  test "should have many sessions" do
    user = User.new(@user_attributes)
    assert_respond_to user, :sessions
  end

  test "should have many habits" do
    user = User.new(@user_attributes)
    assert_respond_to user, :habits
  end

  test "should have many habit_entries through habits" do
    user = User.new(@user_attributes)
    assert_respond_to user, :habit_entries
  end

  test "should have many daily_reflections" do
    user = User.new(@user_attributes)
    assert_respond_to user, :daily_reflections
  end

  # Email validation tests
  test "should require email_address" do
    user = User.new(@user_attributes.except(:email_address))
    refute user.valid?
    assert_includes user.errors[:email_address], "can't be blank"
  end

  test "should validate email format" do
    invalid_emails = [ "invalid", "test@", "@example.com", "test@.com", "test @example.com" ]

    invalid_emails.each do |invalid_email|
      user = User.new(@user_attributes.merge(email_address: invalid_email))
      refute user.valid?, "#{invalid_email} should be invalid"
      assert_includes user.errors[:email_address], "must be a valid email address"
    end
  end

  test "should accept valid email formats" do
    valid_emails = [ "user@example.com", "test.user@example.co.uk", "user+tag@example.org" ]

    valid_emails.each do |valid_email|
      user = User.new(@user_attributes.merge(email_address: valid_email))
      assert user.valid?, "#{valid_email} should be valid"
    end
  end

  test "should enforce email uniqueness" do
    User.create!(@user_attributes)

    duplicate_user = User.new(@user_attributes)
    refute duplicate_user.valid?
    assert_includes duplicate_user.errors[:email_address], "has already been taken"
  end

  test "should enforce case-insensitive email uniqueness" do
    User.create!(@user_attributes)

    duplicate_user = User.new(@user_attributes.merge(email_address: "TEST@EXAMPLE.COM"))
    refute duplicate_user.valid?
    assert_includes duplicate_user.errors[:email_address], "has already been taken"
  end

  # Email normalization tests
  test "should normalize email address" do
    user = User.create!(@user_attributes.merge(email_address: "  TEST@EXAMPLE.COM  "))
    assert_equal "test@example.com", user.email_address
  end

  test "should strip whitespace from email" do
    user = User.create!(@user_attributes.merge(email_address: "  test@example.com  "))
    assert_equal "test@example.com", user.email_address
  end

  test "should downcase email" do
    user = User.create!(@user_attributes.merge(email_address: "Test@Example.COM"))
    assert_equal "test@example.com", user.email_address
  end

  # Password tests
  test "should require password" do
    user = User.new(@user_attributes.except(:password))
    refute user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  test "should have secure password" do
    user = User.new(@user_attributes)
    assert_respond_to user, :authenticate
  end

  test "should authenticate with correct password" do
    user = User.create!(@user_attributes)
    assert_equal user, user.authenticate(@user_attributes[:password])
  end

  test "should not authenticate with incorrect password" do
    user = User.create!(@user_attributes)
    refute user.authenticate("wrong_password")
  end

  # Dependent destroy tests
  test "should destroy associated sessions when user is destroyed" do
    user = User.create!(@user_attributes)
    session = user.sessions.create!
    session_id = session.id

    user.destroy

    assert_raises(ActiveRecord::RecordNotFound) do
      Session.find(session_id)
    end
  end

  test "should destroy associated habits when user is destroyed" do
    user = User.create!(@user_attributes)
    habit = user.habits.create!(
      name: "Exercise",
      month: 8,
      year: 2024,
      position: 1,
      check_type: "x_marks"
    )
    habit_id = habit.id

    user.destroy

    assert_raises(ActiveRecord::RecordNotFound) do
      Habit.find(habit_id)
    end
  end

  test "should destroy associated daily_reflections when user is destroyed" do
    user = User.create!(@user_attributes)
    reflection = user.daily_reflections.create!(
      date: Date.current,
      content: "Test reflection"
    )
    reflection_id = reflection.id

    user.destroy

    assert_raises(ActiveRecord::RecordNotFound) do
      DailyReflection.find(reflection_id)
    end
  end

  test "should destroy habit_entries through habits when user is destroyed" do
    user = User.create!(@user_attributes)
    habit = user.habits.create!(
      name: "Exercise",
      month: 8,
      year: 2024,
      position: 1,
      check_type: "x_marks"
    )
    entry = habit.habit_entries.create!(day: 15, completed: true)
    entry_id = entry.id

    user.destroy

    assert_raises(ActiveRecord::RecordNotFound) do
      HabitEntry.find(entry_id)
    end
  end

  # Basic CRUD tests
  test "should create user with valid attributes" do
    user = User.new(@user_attributes)
    assert user.valid?
    assert user.save
  end

  test "should read user attributes" do
    user = User.create!(@user_attributes)

    assert_equal "test@example.com", user.email_address
    assert user.authenticate(@user_attributes[:password])
  end

  test "should update user attributes" do
    user = User.create!(@user_attributes)
    new_email = "updated@example.com"

    user.update!(email_address: new_email)
    user.reload

    assert_equal new_email, user.email_address
  end

  test "should delete user" do
    user = User.create!(@user_attributes)
    user_id = user.id

    user.destroy

    assert_raises(ActiveRecord::RecordNotFound) do
      User.find(user_id)
    end
  end
end
