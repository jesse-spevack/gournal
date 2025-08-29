require "test_helper"

class DailyReflectionTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @daily_reflection_attributes = {
      date: Date.current,
      content: "Today was a great day for reflection.",
      user: @user
    }
  end

  # Association tests
  test "should belong to user" do
    daily_reflection = DailyReflection.new(@daily_reflection_attributes)
    assert_respond_to daily_reflection, :user
    assert_equal @user, daily_reflection.user
  end

  # Presence validation tests
  test "should require date" do
    daily_reflection = DailyReflection.new(@daily_reflection_attributes.except(:date))
    refute daily_reflection.valid?
    assert_includes daily_reflection.errors[:date], "can't be blank"
  end

  test "should not require content" do
    daily_reflection = DailyReflection.new(@daily_reflection_attributes.except(:content))
    assert daily_reflection.valid?
  end

  test "should allow empty content" do
    daily_reflection = DailyReflection.new(@daily_reflection_attributes.merge(content: ""))
    assert daily_reflection.valid?
  end

  test "should allow nil content" do
    daily_reflection = DailyReflection.new(@daily_reflection_attributes.merge(content: nil))
    assert daily_reflection.valid?
  end

  # Content length validation tests
  test "should validate content length maximum 255 characters" do
    long_content = "a" * 256
    daily_reflection = DailyReflection.new(@daily_reflection_attributes.merge(content: long_content))
    refute daily_reflection.valid?
    assert_includes daily_reflection.errors[:content], "is too long (maximum is 255 characters)"
  end

  test "should allow content exactly 255 characters" do
    content_255_chars = "a" * 255
    daily_reflection = DailyReflection.new(@daily_reflection_attributes.merge(content: content_255_chars))
    assert daily_reflection.valid?
  end

  test "should allow content under 255 characters" do
    short_content = "Short reflection."
    daily_reflection = DailyReflection.new(@daily_reflection_attributes.merge(content: short_content))
    assert daily_reflection.valid?
  end

  # Uniqueness validation tests
  test "should validate uniqueness of date scoped to user" do
    # Create first reflection for today
    daily_reflection1 = DailyReflection.create!(@daily_reflection_attributes)
    
    # Try to create second reflection for same user and date
    daily_reflection2 = DailyReflection.new(@daily_reflection_attributes)
    refute daily_reflection2.valid?
    assert_includes daily_reflection2.errors[:date], "has already been taken"
  end

  test "should allow same date for different users" do
    user2 = users(:two)
    
    # Create first reflection for user one
    daily_reflection1 = DailyReflection.create!(@daily_reflection_attributes)
    
    # Create second reflection for user two with same date
    daily_reflection2 = DailyReflection.new(@daily_reflection_attributes.merge(user: user2))
    assert daily_reflection2.valid?
  end

  test "should allow different dates for same user" do
    # Create first reflection for today
    daily_reflection1 = DailyReflection.create!(@daily_reflection_attributes)
    
    # Create second reflection for tomorrow
    daily_reflection2 = DailyReflection.new(@daily_reflection_attributes.merge(date: Date.tomorrow))
    assert daily_reflection2.valid?
  end

  # Database unique index constraint tests
  test "should enforce unique index on user_id and date at database level" do
    # Create first reflection
    daily_reflection1 = DailyReflection.create!(@daily_reflection_attributes)
    
    # Try to create duplicate bypassing validations (should fail at database level)
    daily_reflection2 = DailyReflection.new(@daily_reflection_attributes)
    
    # Should raise database constraint violation
    assert_raises ActiveRecord::RecordNotUnique do
      daily_reflection2.save(validate: false)
    end
  end

  # Basic CRUD tests
  test "should create valid daily reflection" do
    daily_reflection = DailyReflection.new(@daily_reflection_attributes)
    assert daily_reflection.valid?
    assert daily_reflection.save
  end

  test "should read daily reflection attributes" do
    daily_reflection = DailyReflection.create!(@daily_reflection_attributes)
    
    assert_equal @daily_reflection_attributes[:date], daily_reflection.date
    assert_equal @daily_reflection_attributes[:content], daily_reflection.content
    assert_equal @daily_reflection_attributes[:user], daily_reflection.user
  end

  test "should update daily reflection" do
    daily_reflection = DailyReflection.create!(@daily_reflection_attributes)
    new_content = "Updated reflection content."
    
    daily_reflection.update!(content: new_content)
    daily_reflection.reload
    
    assert_equal new_content, daily_reflection.content
  end

  test "should delete daily reflection" do
    daily_reflection = DailyReflection.create!(@daily_reflection_attributes)
    reflection_id = daily_reflection.id
    
    daily_reflection.destroy
    
    assert_raises ActiveRecord::RecordNotFound do
      DailyReflection.find(reflection_id)
    end
  end

  # Edge case tests
  test "should handle past dates" do
    past_date = 1.year.ago.to_date
    daily_reflection = DailyReflection.new(@daily_reflection_attributes.merge(date: past_date))
    assert daily_reflection.valid?
  end

  test "should handle future dates" do
    future_date = 1.year.from_now.to_date
    daily_reflection = DailyReflection.new(@daily_reflection_attributes.merge(date: future_date))
    assert daily_reflection.valid?
  end

  test "should handle special characters in content" do
    special_content = "Today I learned about émojis 🎉 and symbols: @#$%^&*()!"
    daily_reflection = DailyReflection.new(@daily_reflection_attributes.merge(content: special_content))
    assert daily_reflection.valid?
  end

  test "should handle newlines in content" do
    multiline_content = "Line 1\nLine 2\nLine 3"
    daily_reflection = DailyReflection.new(@daily_reflection_attributes.merge(content: multiline_content))
    assert daily_reflection.valid?
  end

  # User association dependency test
  test "should belong to user and be destroyed when user is destroyed" do
    daily_reflection = DailyReflection.create!(@daily_reflection_attributes)
    reflection_id = daily_reflection.id
    
    # This test assumes the association has dependent: :destroy
    @user.destroy
    
    assert_raises ActiveRecord::RecordNotFound do
      DailyReflection.find(reflection_id)
    end
  end
end