require "test_helper"

class CheckboxHelperTest < ActionView::TestCase
  # Test valid parameters
  test "accepts valid fill_variant between 0 and 9" do
    [ :x, :blot ].each do |fill_style|
      (0..9).each do |box_variant|
        (0..9).each do |fill_variant|
          assert_nothing_raised do
            habit_checkbox(box_variant: box_variant, fill_variant: fill_variant, fill_style: fill_style)
          end
        end
      end
    end
  end

  # Test invalid parameters
  test "raises error for invalid box_variant below range" do
    assert_raises(ArgumentError, "Invalid box_variant: must be 0-9 (got -1)") do
      habit_checkbox(box_variant: -1, fill_variant: 0, fill_style: :x)
    end
  end

  test "raises error for invalid box_variant above range" do
    assert_raises(ArgumentError, "Invalid box_variant: must be 0-9 (got 10)") do
      habit_checkbox(box_variant: 10, fill_variant: 0, fill_style: :x)
    end
  end

  test "raises error for invalid fill_variant below range" do
    assert_raises(ArgumentError, "Invalid fill_variant: must be 0-9 (got -1)") do
      habit_checkbox(box_variant: 0, fill_variant: -1, fill_style: :x)
    end
  end

  test "raises error for invalid fill_variant above range" do
    assert_raises(ArgumentError, "Invalid fill_variant: must be 0-9 (got 10)") do
      habit_checkbox(box_variant: 0, fill_variant: 10, fill_style: :x)
    end
  end

  test "raises error for invalid fill_style" do
    assert_raises(ArgumentError, "Invalid fill_style: must be blot, x (got :invalid)") do
      habit_checkbox(box_variant: 0, fill_variant: 0, fill_style: :invalid)
    end
  end

  test "raises error for non-integer box_variant" do
    assert_raises(ArgumentError) do
      habit_checkbox(box_variant: "invalid", fill_variant: 0, fill_style: :x)
    end
  end

  test "raises error for non-integer fill_variant" do
    assert_raises(ArgumentError) do
      habit_checkbox(box_variant: 0, fill_variant: "invalid", fill_style: :x)
    end
  end

  test "raises error for non-symbol fill_style" do
    assert_raises(ArgumentError) do
      habit_checkbox(box_variant: 0, fill_variant: 0, fill_style: "invalid")
    end
  end

  test "raises error for integer fill_style" do
    assert_raises(ArgumentError) do
      habit_checkbox(box_variant: 0, fill_variant: 0, fill_style: 123)
    end
  end

  test "raises error for float box_variant" do
    assert_raises(ArgumentError) do
      habit_checkbox(box_variant: 1.5)
    end
  end

  test "raises error for float fill_variant" do
    assert_raises(ArgumentError) do
      habit_checkbox(box_variant: 0, fill_variant: 1.5, fill_style: :x)
    end
  end

  # Test unfilled checkbox support
  test "accepts unfilled checkbox with only box_variant" do
    (0..9).each do |box_variant|
      assert_nothing_raised do
        result = habit_checkbox(box_variant: box_variant)
        assert_includes result, "checkbox-container"
        assert_includes result, "checkbox-box"
        # Should not include any fill partial content
        refute_includes result, "checkbox-fill"
        refute_includes result, "Ink blot variation"
        refute_includes result, "X mark variation"
      end
    end
  end

  test "accepts unfilled checkbox with nil fill_variant and fill_style" do
    assert_nothing_raised do
      result = habit_checkbox(box_variant: 3, fill_variant: nil, fill_style: nil)
      assert_includes result, "checkbox-container"
      assert_includes result, "checkbox-box"
      refute_includes result, "checkbox-fill"
    end
  end

  test "raises error when only fill_variant is provided without fill_style" do
    assert_raises(ArgumentError, "fill_style is required when fill_variant is provided") do
      habit_checkbox(box_variant: 0, fill_variant: 5)
    end
  end

  test "raises error when only fill_style is provided without fill_variant" do
    assert_raises(ArgumentError, "fill_variant is required when fill_style is provided") do
      habit_checkbox(box_variant: 0, fill_style: :x)
    end
  end

  test "accepts filled checkbox with both fill_variant and fill_style" do
    assert_nothing_raised do
      result = habit_checkbox(box_variant: 2, fill_variant: 7, fill_style: :blot)
      assert_includes result, "checkbox-container"
      assert_includes result, "checkbox-box"
      assert_includes result, "checkbox-fill"
      assert_includes result, "Ink blot variation 7"
    end
  end

  # Tests for render_habit_checkbox helper method
  test "render_habit_checkbox renders unchecked entry correctly" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    habit = Habit.create!(
      user: user,
      name: "Test Habit",
      month: 1,
      year: 2024,
      position: 1,
      check_type: "x_marks"
    )
    entry = HabitEntry.create!(
      habit: habit,
      day: 15,
      checkbox_style: "box_style_0",
      completed: false
    )

    result = render_habit_checkbox(entry)

    assert_not_nil result
    assert_includes result, "<svg"
    assert_includes result, 'viewBox="0 0 24 24"'
    assert_includes result, 'class="checkbox__box-path"'
    refute_includes result, 'class="checkbox__mark"'
    refute_includes result, 'class="checkbox__fill"'
  end

  test "render_habit_checkbox renders checked x_marks entry correctly" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    habit = Habit.create!(
      user: user,
      name: "Test Habit",
      month: 1,
      year: 2024,
      position: 1,
      check_type: "x_marks"
    )
    entry = HabitEntry.create!(
      habit: habit,
      day: 15,
      checkbox_style: "box_style_1",
      check_style: "x_style_2",
      completed: true
    )

    result = render_habit_checkbox(entry)

    assert_not_nil result
    assert_includes result, "<svg"
    assert_includes result, 'class="checkbox__box-path"'
    assert_includes result, 'class="checkbox__x-path"'
    refute_includes result, 'class="checkbox__fill"'
  end

  test "render_habit_checkbox renders checked blots entry correctly" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    habit = Habit.create!(
      user: user,
      name: "Test Habit",
      month: 1,
      year: 2024,
      position: 1,
      check_type: "blots"
    )
    entry = HabitEntry.create!(
      habit: habit,
      day: 15,
      checkbox_style: "box_style_3",
      check_style: "blot_style_4",
      completed: true
    )

    result = render_habit_checkbox(entry)

    assert_not_nil result
    assert_includes result, "<svg"
    assert_includes result, 'class="checkbox__box-path"'
    assert_includes result, 'class="checkbox__fill"'
    refute_includes result, 'class="checkbox__x-path"'
  end

  test "render_habit_checkbox accepts custom CSS class" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    habit = Habit.create!(
      user: user,
      name: "Test Habit",
      month: 1,
      year: 2024,
      position: 1,
      check_type: "x_marks"
    )
    entry = HabitEntry.create!(
      habit: habit,
      day: 15,
      checkbox_style: "box_style_0",
      completed: false
    )

    result = render_habit_checkbox(entry, css_class: "custom-habit-checkbox")

    assert_includes result, 'class="custom-habit-checkbox"'
  end

  test "render_habit_checkbox raises error for nil entry" do
    assert_raises(ArgumentError, "entry is required") do
      render_habit_checkbox(nil)
    end
  end

  test "render_habit_checkbox works with different combinations of styles" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    x_habit = Habit.create!(
      user: user,
      name: "X Habit",
      month: 1,
      year: 2024,
      position: 1,
      check_type: "x_marks"
    )
    blot_habit = Habit.create!(
      user: user,
      name: "Blot Habit",
      month: 1,
      year: 2024,
      position: 2,
      check_type: "blots"
    )

    # Test various combinations
    combinations = [
      { habit: x_habit, box: "box_style_0", check: "x_style_0", completed: true },
      { habit: x_habit, box: "box_style_5", check: "x_style_7", completed: true },
      { habit: blot_habit, box: "box_style_2", check: "blot_style_3", completed: true },
      { habit: blot_habit, box: "box_style_9", check: "blot_style_9", completed: true },
      { habit: x_habit, box: "box_style_4", check: nil, completed: false },
      { habit: blot_habit, box: "box_style_8", check: nil, completed: false }
    ]

    combinations.each_with_index do |combo, index|
      entry = HabitEntry.create!(
        habit: combo[:habit],
        day: index + 1,
        checkbox_style: combo[:box],
        check_style: combo[:check],
        completed: combo[:completed]
      )

      assert_nothing_raised do
        result = render_habit_checkbox(entry)
        assert_not_nil result
        assert_includes result, "<svg"
      end
    end
  end
end
