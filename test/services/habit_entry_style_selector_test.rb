require "test_helper"

class HabitEntryStyleSelectorTest < ActiveSupport::TestCase
  test "random_checkbox_style returns a valid checkbox style" do
    style = HabitEntryStyleSelector.random_checkbox_style

    assert_not_nil style
    assert_includes HabitEntry.checkbox_styles.keys, style
  end

  test "random_checkbox_style returns different values on multiple calls" do
    # Run enough times to ensure we get variety (probabilistic test)
    styles = 20.times.map { HabitEntryStyleSelector.random_checkbox_style }

    # Should have at least 2 different styles (extremely unlikely to get same 20 times)
    assert styles.uniq.length > 1, "Expected variety in random checkbox styles"
  end

  test "random_check_style_for returns x_style for x_marks check type" do
    style = HabitEntryStyleSelector.random_check_style_for(Habit::CHECK_TYPE_X_MARKS)

    assert_not_nil style
    assert style.start_with?("x_style_"), "Expected x_style but got #{style}"
  end

  test "random_check_style_for returns blot_style for blots check type" do
    style = HabitEntryStyleSelector.random_check_style_for(Habit::CHECK_TYPE_BLOTS)

    assert_not_nil style
    assert style.start_with?("blot_style_"), "Expected blot_style but got #{style}"
  end

  test "random_check_style_for returns any check style for unknown check type" do
    style = HabitEntryStyleSelector.random_check_style_for("unknown_type")

    assert_not_nil style
    assert_includes HabitEntry.check_styles.keys, style
  end

  test "random_check_style_for returns variety for x_marks" do
    # Run enough times to ensure we get variety
    styles = 20.times.map { HabitEntryStyleSelector.random_check_style_for(Habit::CHECK_TYPE_X_MARKS) }

    # Should have at least 2 different styles
    assert styles.uniq.length > 1, "Expected variety in random x_marks styles"
    # All should be x_styles
    assert styles.all? { |s| s.start_with?("x_style_") }
  end

  test "random_check_style_for returns variety for blots" do
    # Run enough times to ensure we get variety
    styles = 20.times.map { HabitEntryStyleSelector.random_check_style_for(Habit::CHECK_TYPE_BLOTS) }

    # Should have at least 2 different styles
    assert styles.uniq.length > 1, "Expected variety in random blot styles"
    # All should be blot_styles
    assert styles.all? { |s| s.start_with?("blot_style_") }
  end

  test "x_style_options returns array of x_style keys" do
    options = HabitEntryStyleSelector.x_style_options

    assert_kind_of Array, options
    assert options.length > 0
    assert options.all? { |k| k.start_with?("x_style_") }
  end

  test "blot_style_options returns array of blot_style keys" do
    options = HabitEntryStyleSelector.blot_style_options

    assert_kind_of Array, options
    assert options.length > 0
    assert options.all? { |k| k.start_with?("blot_style_") }
  end

  test "x_style_options returns exactly 10 styles" do
    options = HabitEntryStyleSelector.x_style_options

    assert_equal 10, options.length
  end

  test "blot_style_options returns exactly 10 styles" do
    options = HabitEntryStyleSelector.blot_style_options

    assert_equal 10, options.length
  end

  test "x_style_options and blot_style_options have no overlap" do
    x_options = HabitEntryStyleSelector.x_style_options
    blot_options = HabitEntryStyleSelector.blot_style_options

    overlap = x_options & blot_options
    assert_empty overlap, "x_style and blot_style options should not overlap"
  end

  test "x_style_options returns consistent results" do
    first_call = HabitEntryStyleSelector.x_style_options
    second_call = HabitEntryStyleSelector.x_style_options

    assert_equal first_call, second_call
  end

  test "blot_style_options returns consistent results" do
    first_call = HabitEntryStyleSelector.blot_style_options
    second_call = HabitEntryStyleSelector.blot_style_options

    assert_equal first_call, second_call
  end
end
