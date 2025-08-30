require "test_helper"

class HabitEntryTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @habit = Habit.create!(
      name: "Exercise",
      month: 8,
      year: 2025,
      position: 1,
      user: @user,
      check_type: "x_marks"
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
      user: @user,
      check_type: "blots"
    )

    # Create entry for first habit
    entry1 = HabitEntry.create!(@entry_attributes)

    # Create entry for second habit with same day
    entry2 = HabitEntry.new(@entry_attributes.merge(habit: habit2))
    assert entry2.valid?
  end

  # Checkbox and check style enum tests
  test "should have checkbox_style enum with box_style_0 through box_style_9" do
    assert_respond_to HabitEntry, :checkbox_styles

    expected_styles = {
      "box_style_0" => 0,
      "box_style_1" => 1,
      "box_style_2" => 2,
      "box_style_3" => 3,
      "box_style_4" => 4,
      "box_style_5" => 5,
      "box_style_6" => 6,
      "box_style_7" => 7,
      "box_style_8" => 8,
      "box_style_9" => 9
    }

    assert_equal expected_styles, HabitEntry.checkbox_styles
  end

  test "should have check_style enum with x_style_0 through x_style_9 and blot_style_0 through blot_style_9" do
    assert_respond_to HabitEntry, :check_styles

    expected_styles = {
      "x_style_0" => 0,
      "x_style_1" => 1,
      "x_style_2" => 2,
      "x_style_3" => 3,
      "x_style_4" => 4,
      "x_style_5" => 5,
      "x_style_6" => 6,
      "x_style_7" => 7,
      "x_style_8" => 8,
      "x_style_9" => 9,
      "blot_style_0" => 10,
      "blot_style_1" => 11,
      "blot_style_2" => 12,
      "blot_style_3" => 13,
      "blot_style_4" => 14,
      "blot_style_5" => 15,
      "blot_style_6" => 16,
      "blot_style_7" => 17,
      "blot_style_8" => 18,
      "blot_style_9" => 19
    }

    assert_equal expected_styles, HabitEntry.check_styles
  end

  test "should allow setting check_style to x_style values" do
    x_styles = HabitEntry.check_styles.keys.select { |k| k.start_with?("x_style_") }
    x_styles.each do |style|
      entry = HabitEntry.new(@entry_attributes.merge(check_style: style))
      entry.valid? # May fail for other reasons, but check_style should be valid
      refute_includes entry.errors.attribute_names, :check_style
    end
  end

  test "should allow setting check_style to blot_style values" do
    blot_styles = HabitEntry.check_styles.keys.select { |k| k.start_with?("blot_style_") }
    blot_styles.each do |style|
      entry = HabitEntry.new(@entry_attributes.merge(check_style: style))
      entry.valid? # May fail for other reasons, but check_style should be valid
      refute_includes entry.errors.attribute_names, :check_style
    end
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
        user: @user,
        check_type: i.even? ? "x_marks" : "blots"
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

  # Check type consistency tests
  test "all habit entries for x_marks habit should use x_style check styles" do
    # Create habit with x_marks check type
    habit = Habit.create!(
      name: "X Marks Habit",
      month: 8,
      year: 2025,
      position: 99,
      user: @user,
      check_type: "x_marks"
    )

    # Create multiple entries for this habit
    entries = []
    5.times do |i|
      entry = HabitEntry.create!(
        habit: habit,
        day: i + 1,
        completed: false
      )
      entries << entry
    end

    # All entries should have x_style check styles
    entries.each do |entry|
      assert entry.check_style.start_with?("x_style_"),
             "Expected x_style check style for x_marks habit, got: #{entry.check_style}"
    end
  end

  test "all habit entries for blots habit should use blot_style check styles" do
    # Create habit with blots check type
    habit = Habit.create!(
      name: "Blots Habit",
      month: 8,
      year: 2025,
      position: 100,
      user: @user,
      check_type: "blots"
    )

    # Create multiple entries for this habit
    entries = []
    5.times do |i|
      entry = HabitEntry.create!(
        habit: habit,
        day: i + 1,
        completed: false
      )
      entries << entry
    end

    # All entries should have blot_style check styles
    entries.each do |entry|
      assert entry.check_style.start_with?("blot_style_"),
             "Expected blot_style check style for blots habit, got: #{entry.check_style}"
    end
  end

  test "habit entries should have varied styles within the same check type" do
    # Create habit with x_marks check type
    x_habit = Habit.create!(
      name: "X Varied Habit",
      month: 8,
      year: 2025,
      position: 101,
      user: @user,
      check_type: "x_marks"
    )

    # Create many entries to ensure variation
    x_entries = []
    15.times do |i|
      entry = HabitEntry.create!(
        habit: x_habit,
        day: i + 1,
        completed: false
      )
      x_entries << entry
    end

    # Should have variation in x_style values
    x_styles = x_entries.map(&:check_style).uniq
    assert x_styles.length > 1, "Expected variation in x_style values, got: #{x_styles}"

    # Create habit with blots check type
    blot_habit = Habit.create!(
      name: "Blot Varied Habit",
      month: 9,
      year: 2025,
      position: 102,
      user: @user,
      check_type: "blots"
    )

    # Create many entries to ensure variation
    blot_entries = []
    15.times do |i|
      entry = HabitEntry.create!(
        habit: blot_habit,
        day: i + 1,
        completed: false
      )
      blot_entries << entry
    end

    # Should have variation in blot_style values
    blot_styles = blot_entries.map(&:check_style).uniq
    assert blot_styles.length > 1, "Expected variation in blot_style values, got: #{blot_styles}"
  end

  test "should assign check_style based on habit check_type during creation" do
    # Test x_marks habit
    x_habit = Habit.create!(
      name: "X Marks Test",
      month: 8,
      year: 2025,
      position: 103,
      user: @user,
      check_type: "x_marks"
    )

    x_entry = HabitEntry.create!(
      habit: x_habit,
      day: 1,
      completed: false
    )

    assert x_entry.check_style.start_with?("x_style_"),
           "Expected x_style for x_marks habit, got: #{x_entry.check_style}"

    # Test blots habit
    blot_habit = Habit.create!(
      name: "Blots Test",
      month: 8,
      year: 2025,
      position: 104,
      user: @user,
      check_type: "blots"
    )

    blot_entry = HabitEntry.create!(
      habit: blot_habit,
      day: 1,
      completed: false
    )

    assert blot_entry.check_style.start_with?("blot_style_"),
           "Expected blot_style for blots habit, got: #{blot_entry.check_style}"
  end

  test "should not assign inappropriate check_style for habit check_type" do
    # Create habit with x_marks check type
    x_habit = Habit.create!(
      name: "X Only Habit",
      month: 8,
      year: 2025,
      position: 105,
      user: @user,
      check_type: "x_marks"
    )

    # Create many entries - none should get blot_style
    entries = []
    20.times do |i|
      entry = HabitEntry.create!(
        habit: x_habit,
        day: i + 1,
        completed: false
      )
      entries << entry
    end

    entries.each do |entry|
      refute entry.check_style.start_with?("blot_style_"),
             "x_marks habit should not have blot_style, got: #{entry.check_style}"
    end

    # Create habit with blots check type
    blot_habit = Habit.create!(
      name: "Blot Only Habit",
      month: 9,
      year: 2025,
      position: 106,
      user: @user,
      check_type: "blots"
    )

    # Create many entries - none should get x_style
    blot_entries = []
    20.times do |i|
      entry = HabitEntry.create!(
        habit: blot_habit,
        day: i + 1,
        completed: false
      )
      blot_entries << entry
    end

    blot_entries.each do |entry|
      refute entry.check_style.start_with?("x_style_"),
             "blots habit should not have x_style, got: #{entry.check_style}"
    end
  end
end
