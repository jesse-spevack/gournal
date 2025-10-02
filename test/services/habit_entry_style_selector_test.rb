require "test_helper"

class HabitEntryStyleSelectorTest < ActiveSupport::TestCase
  test "random_checkbox_style returns valid checkbox style" do
    style = HabitEntryStyleSelector.random_checkbox_style

    assert_includes HabitEntry.checkbox_styles.keys, style
  end

  test "random_check_style_for returns x_style for x_marks check type" do
    style = HabitEntryStyleSelector.random_check_style_for(Habit::CHECK_TYPE_X_MARKS)

    assert style.start_with?("x_style_")
  end

  test "random_check_style_for returns blot_style for blots check type" do
    style = HabitEntryStyleSelector.random_check_style_for(Habit::CHECK_TYPE_BLOTS)

    assert style.start_with?("blot_style_")
  end

  test "random_check_style_for returns any check style for unknown check type" do
    style = HabitEntryStyleSelector.random_check_style_for("unknown_type")

    assert_includes HabitEntry.check_styles.keys, style
  end

  test "style options are correctly partitioned" do
    x_options = HabitEntryStyleSelector.x_style_options
    blot_options = HabitEntryStyleSelector.blot_style_options

    assert_equal 10, x_options.length
    assert_equal 10, blot_options.length
    assert_empty x_options & blot_options
  end
end
