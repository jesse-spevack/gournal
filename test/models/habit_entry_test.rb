require "test_helper"

class HabitEntryTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @habit = Habit.create!(
      name: "Exercise",
      month: 8,
      year: 2025,
      position: 1,
      user: @user
    )
    @entry_attributes = {
      day: 15,
      completed: false,
      habit: @habit
    }
  end

  # Association tests
  test "should belong to habit" do
    entry = HabitEntry.new(@entry_attributes)
    assert_respond_to entry, :habit
    assert_equal @habit, entry.habit
  end

  # Field presence and basic validation tests
  test "should require day" do
    entry = HabitEntry.new(@entry_attributes.except(:day))
    refute entry.valid?
    assert_includes entry.errors[:day], "can't be blank"
  end

  test "should have completed field with default false" do
    entry = HabitEntry.new(@entry_attributes.except(:completed))
    # Should default to false
    assert_equal false, entry.completed
  end

  test "should allow setting completed to true" do
    entry = HabitEntry.new(@entry_attributes.merge(completed: true))
    assert entry.completed
  end

  test "should allow setting completed to false" do
    entry = HabitEntry.new(@entry_attributes.merge(completed: false))
    refute entry.completed
  end

  # Day validation tests (1-31)
  test "should validate day is between 1 and 31" do
    # Test day 0 (invalid)
    entry = HabitEntry.new(@entry_attributes.merge(day: 0))
    refute entry.valid?
    assert_includes entry.errors[:day], "must be greater than or equal to 1"

    # Test day 32 (invalid) 
    entry = HabitEntry.new(@entry_attributes.merge(day: 32))
    refute entry.valid?
    assert_includes entry.errors[:day], "must be less than or equal to 31"

    # Test day 1 (valid)
    entry = HabitEntry.new(@entry_attributes.merge(day: 1))
    entry.valid? # May fail for other reasons, but day should be valid
    refute_includes entry.errors[:day], "must be greater than or equal to 1"
    refute_includes entry.errors[:day], "must be less than or equal to 31"

    # Test day 31 (valid)
    entry = HabitEntry.new(@entry_attributes.merge(day: 31))
    entry.valid? # May fail for other reasons, but day should be valid
    refute_includes entry.errors[:day], "must be greater than or equal to 1"
    refute_includes entry.errors[:day], "must be less than or equal to 31"

    # Test day 15 (valid)
    entry = HabitEntry.new(@entry_attributes.merge(day: 15))
    entry.valid? # May fail for other reasons, but day should be valid
    refute_includes entry.errors[:day], "must be greater than or equal to 1"
    refute_includes entry.errors[:day], "must be less than or equal to 31"
  end

  # Uniqueness constraint tests
  test "should have unique day per habit" do
    # Create first entry
    entry1 = HabitEntry.create!(@entry_attributes)

    # Try to create second entry with same day and habit
    entry2 = HabitEntry.new(@entry_attributes)
    refute entry2.valid?
    assert_includes entry2.errors[:day], "has already been taken"
  end

  test "should allow same day for different habits" do
    habit2 = Habit.create!(
      name: "Reading",
      month: 8, 
      year: 2025,
      position: 2,
      user: @user
    )

    # Create entry for first habit
    entry1 = HabitEntry.create!(@entry_attributes)

    # Create entry for second habit with same day
    entry2 = HabitEntry.new(@entry_attributes.merge(habit: habit2))
    assert entry2.valid?
  end

  # Checkbox and check style enum tests
  test "should have checkbox_style enum with box_style_1 through box_style_5" do
    assert_respond_to HabitEntry, :checkbox_styles
    
    expected_styles = {
      "box_style_1" => 0,
      "box_style_2" => 1,
      "box_style_3" => 2,
      "box_style_4" => 3,
      "box_style_5" => 4
    }
    
    assert_equal expected_styles, HabitEntry.checkbox_styles
  end

  test "should have check_style enum with x_style_1 through x_style_5" do
    assert_respond_to HabitEntry, :check_styles
    
    expected_styles = {
      "x_style_1" => 0,
      "x_style_2" => 1,
      "x_style_3" => 2,
      "x_style_4" => 3,
      "x_style_5" => 4
    }
    
    assert_equal expected_styles, HabitEntry.check_styles
  end

  test "should allow setting checkbox_style to valid values" do
    HabitEntry.checkbox_styles.keys.each do |style|
      entry = HabitEntry.new(@entry_attributes.merge(checkbox_style: style))
      entry.valid? # May fail for other reasons, but checkbox_style should be valid
      refute_includes entry.errors.attribute_names, :checkbox_style
    end
  end

  test "should allow setting check_style to valid values" do
    HabitEntry.check_styles.keys.each do |style|
      entry = HabitEntry.new(@entry_attributes.merge(check_style: style))
      entry.valid? # May fail for other reasons, but check_style should be valid
      refute_includes entry.errors.attribute_names, :check_style
    end
  end

  test "should reject invalid checkbox_style values" do
    assert_raises(ArgumentError) do
      HabitEntry.new(@entry_attributes.merge(checkbox_style: "invalid_style"))
    end
  end

  test "should reject invalid check_style values" do
    assert_raises(ArgumentError) do
      HabitEntry.new(@entry_attributes.merge(check_style: "invalid_style"))
    end
  end

  # Random style assignment tests
  test "should assign random checkbox_style before creation" do
    entry = HabitEntry.new(@entry_attributes)
    
    # Should not have style assigned yet
    assert_nil entry.checkbox_style
    
    # After save, should have a random style assigned
    entry.save!
    assert_not_nil entry.checkbox_style
    assert_includes HabitEntry.checkbox_styles.keys, entry.checkbox_style
  end

  test "should assign random check_style before creation" do
    entry = HabitEntry.new(@entry_attributes)
    
    # Should not have style assigned yet
    assert_nil entry.check_style
    
    # After save, should have a random style assigned  
    entry.save!
    assert_not_nil entry.check_style
    assert_includes HabitEntry.check_styles.keys, entry.check_style
  end

  test "should assign different random styles to different entries" do
    # Create many entries to increase likelihood of getting different styles
    entries = []
    20.times do |i|
      habit = Habit.create!(
        name: "Habit #{i}",
        month: 8,
        year: 2025, 
        position: i + 10, # Start from position 10 to avoid conflict with setup
        user: @user
      )
      entry = HabitEntry.create!(@entry_attributes.merge(habit: habit, day: i + 1))
      entries << entry
    end
    
    # Should have some variation in checkbox styles
    checkbox_styles = entries.map(&:checkbox_style).uniq
    assert checkbox_styles.length > 1, "Expected multiple different checkbox styles, got: #{checkbox_styles}"
    
    # Should have some variation in check styles
    check_styles = entries.map(&:check_style).uniq
    assert check_styles.length > 1, "Expected multiple different check styles, got: #{check_styles}"
  end

  test "should not change checkbox_style after creation" do
    entry = HabitEntry.create!(@entry_attributes)
    original_checkbox_style = entry.checkbox_style
    
    # Update the entry
    entry.update!(completed: true)
    entry.reload
    
    # Style should remain the same
    assert_equal original_checkbox_style, entry.checkbox_style
  end

  test "should not change check_style after creation" do
    entry = HabitEntry.create!(@entry_attributes)
    original_check_style = entry.check_style
    
    # Update the entry
    entry.update!(completed: true)
    entry.reload
    
    # Style should remain the same
    assert_equal original_check_style, entry.check_style
  end

  test "should not override manually set checkbox_style during creation" do
    entry = HabitEntry.new(@entry_attributes.merge(checkbox_style: "box_style_3"))
    entry.save!
    
    # Should keep the manually set style
    assert_equal "box_style_3", entry.checkbox_style
  end

  test "should not override manually set check_style during creation" do
    entry = HabitEntry.new(@entry_attributes.merge(check_style: "x_style_4"))
    entry.save!
    
    # Should keep the manually set style
    assert_equal "x_style_4", entry.check_style
  end

  # Future date validation tests
  test "should not allow completing future dates" do
    # Set up a future date
    future_date = Date.current.day + 1
    # Handle month rollover
    if future_date > 31
      future_date = 1
    end
    
    entry = HabitEntry.new(@entry_attributes.merge(day: future_date, completed: true))
    refute entry.valid?
    assert_includes entry.errors[:completed], "cannot be completed for future dates"
  end

  test "should allow completing current date" do
    current_day = Date.current.day
    
    entry = HabitEntry.new(@entry_attributes.merge(day: current_day, completed: true))
    entry.valid? # May fail for other reasons, but future date validation should pass
    refute_includes entry.errors[:completed], "cannot be completed for future dates"
  end

  test "should allow completing past dates" do
    past_day = Date.current.day - 1
    # Handle month underflow
    if past_day < 1
      past_day = 31
    end
    
    entry = HabitEntry.new(@entry_attributes.merge(day: past_day, completed: true))
    entry.valid? # May fail for other reasons, but future date validation should pass  
    refute_includes entry.errors[:completed], "cannot be completed for future dates"
  end

  test "should allow creating uncompleted future dates" do
    future_date = Date.current.day + 1
    # Handle month rollover
    if future_date > 31
      future_date = 1
    end
    
    entry = HabitEntry.new(@entry_attributes.merge(day: future_date, completed: false))
    entry.valid? # May fail for other reasons, but future date validation should pass
    refute_includes entry.errors[:completed], "cannot be completed for future dates"
  end

  test "should validate against current month and year for future date checking" do
    # Create a habit for current month/year
    current_habit = Habit.create!(
      name: "Current Exercise",
      month: Date.current.month,
      year: Date.current.year,
      position: 99, # Use a position that won't conflict
      user: @user
    )
    
    future_day = Date.current.day + 1
    # Handle month rollover
    if future_day > 31
      future_day = 1
    end
    
    entry = HabitEntry.new(
      habit: current_habit,
      day: future_day,
      completed: true
    )
    
    refute entry.valid?
    assert_includes entry.errors[:completed], "cannot be completed for future dates"
  end

  test "should allow completion for past month entries regardless of day" do
    # Create habit for previous month
    past_habit = Habit.create!(
      name: "Past Exercise", 
      month: Date.current.month == 1 ? 12 : Date.current.month - 1,
      year: Date.current.month == 1 ? Date.current.year - 1 : Date.current.year,
      position: 1,
      user: @user
    )
    
    entry = HabitEntry.new(
      habit: past_habit,
      day: 31, # Any day in past month should be allowed
      completed: true
    )
    
    entry.valid? # May fail for other reasons, but future date validation should pass
    refute_includes entry.errors[:completed], "cannot be completed for future dates"
  end
end