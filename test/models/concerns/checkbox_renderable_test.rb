require "test_helper"

class CheckboxRenderableTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email_address: "test@example.com", password: "password123")
    @habit = Habit.create!(
      user: @user,
      name: "Test Habit",
      month: 1,
      year: 2024,
      position: 1,
      check_type: "x_marks"
    )
  end

  test "habit entry includes CheckboxRenderable concern" do
    entry = HabitEntry.new(habit: @habit, day: 15)
    assert_respond_to entry, :checkbox_box_path
    assert_respond_to entry, :checkbox_check_path
    assert_respond_to entry, :render_checkbox_svg
  end

  test "checkbox_box_path returns correct SVG path for different box styles" do
    entry = HabitEntry.create!(habit: @habit, day: 15, checkbox_style: "box_style_0")
    box_path = entry.checkbox_box_path

    assert_not_nil box_path
    assert_instance_of String, box_path
    assert_includes box_path, "M "  # SVG path should start with move command
    assert box_path.length > 10     # Should be a substantial path string
  end

  test "different box styles return different paths" do
    entry1 = HabitEntry.create!(habit: @habit, day: 15, checkbox_style: "box_style_0")
    entry2 = HabitEntry.create!(habit: @habit, day: 16, checkbox_style: "box_style_1")

    path1 = entry1.checkbox_box_path
    path2 = entry2.checkbox_box_path

    refute_equal path1, path2
  end

  test "checkbox_check_path returns correct SVG path for different check styles" do
    entry = HabitEntry.create!(habit: @habit, day: 15, check_style: "x_style_0")
    check_path = entry.checkbox_check_path

    assert_not_nil check_path
    assert_instance_of String, check_path
    assert_includes check_path, "M "  # SVG path should start with move command
  end

  test "different check styles return different paths" do
    entry1 = HabitEntry.create!(habit: @habit, day: 15, check_style: "x_style_0")
    entry2 = HabitEntry.create!(habit: @habit, day: 16, check_style: "x_style_1")

    path1 = entry1.checkbox_check_path
    path2 = entry2.checkbox_check_path

    refute_equal path1, path2
  end

  test "checkbox_check_type returns correct type for x_marks habit" do
    entry = HabitEntry.create!(habit: @habit, day: 15, check_style: "x_style_0")
    assert_equal :x_mark, entry.checkbox_check_type
  end

  test "checkbox_check_type returns correct type for blots habit" do
    blot_habit = Habit.create!(
      user: @user,
      name: "Blot Habit",
      month: 2,
      year: 2024,
      position: 1,
      check_type: "blots"
    )
    entry = HabitEntry.create!(habit: blot_habit, day: 15, check_style: "blot_style_0")

    assert_equal :blot, entry.checkbox_check_type
  end

  test "render_checkbox_svg generates SVG for unchecked entry" do
    entry = HabitEntry.create!(
      habit: @habit,
      day: 15,
      checkbox_style: "box_style_0",
      completed: false
    )

    svg = entry.render_checkbox_svg

    assert_not_nil svg
    assert_includes svg, "<svg"
    assert_includes svg, 'viewBox="0 0 24 24"'
    assert_includes svg, 'class="checkbox__box-path"'
    refute_includes svg, 'class="checkbox__mark"'
    refute_includes svg, 'class="checkbox__fill"'
  end

  test "render_checkbox_svg generates SVG for checked x_marks entry" do
    entry = HabitEntry.create!(
      habit: @habit,
      day: 15,
      checkbox_style: "box_style_0",
      check_style: "x_style_0",
      completed: true
    )

    svg = entry.render_checkbox_svg

    assert_not_nil svg
    assert_includes svg, "<svg"
    assert_includes svg, 'class="checkbox__box-path"'
    assert_includes svg, 'class="checkbox__x-path"'
    refute_includes svg, 'class="checkbox__fill"'
  end

  test "render_checkbox_svg generates SVG for checked blots entry" do
    blot_habit = Habit.create!(
      user: @user,
      name: "Blot Habit",
      month: 3,
      year: 2024,
      position: 1,
      check_type: "blots"
    )
    entry = HabitEntry.create!(
      habit: blot_habit,
      day: 15,
      checkbox_style: "box_style_0",
      check_style: "blot_style_0",
      completed: true
    )

    svg = entry.render_checkbox_svg

    assert_not_nil svg
    assert_includes svg, "<svg"
    assert_includes svg, 'class="checkbox__box-path"'
    assert_includes svg, 'class="checkbox__fill"'
    refute_includes svg, 'class="checkbox__x-path"'
  end

  test "render_checkbox_svg with custom CSS class" do
    entry = HabitEntry.create!(
      habit: @habit,
      day: 15,
      checkbox_style: "box_style_0",
      completed: false
    )

    svg = entry.render_checkbox_svg(css_class: "custom-checkbox")

    assert_includes svg, 'class="custom-checkbox"'
  end

  test "all box styles have valid SVG paths stored" do
    (0..9).each do |style_num|
      entry = HabitEntry.create!(
        habit: @habit,
        day: 15 + style_num,
        checkbox_style: "box_style_#{style_num}"
      )

      path = entry.checkbox_box_path
      assert_not_nil path, "box_style_#{style_num} should have a path"
      assert path.length > 10, "box_style_#{style_num} path should be substantial"
      assert_includes path, "M ", "box_style_#{style_num} should be valid SVG path"
    end
  end

  test "all x check styles have valid SVG paths stored" do
    (0..9).each do |style_num|
      entry = HabitEntry.create!(
        habit: @habit,
        day: 15 + style_num,
        check_style: "x_style_#{style_num}"
      )

      path = entry.checkbox_check_path
      assert_not_nil path, "x_style_#{style_num} should have a path"
      assert path.length > 10, "x_style_#{style_num} path should be substantial"
      assert_includes path, "M ", "x_style_#{style_num} should be valid SVG path"
    end
  end

  test "all blot check styles have valid SVG paths stored" do
    blot_habit = Habit.create!(
      user: @user,
      name: "Blot Habit",
      month: 4,
      year: 2024,
      position: 1,
      check_type: "blots"
    )

    (0..9).each do |style_num|
      entry = HabitEntry.create!(
        habit: blot_habit,
        day: 15 + style_num,
        check_style: "blot_style_#{style_num}"
      )

      path = entry.checkbox_check_path
      assert_not_nil path, "blot_style_#{style_num} should have a path"
      assert path.length > 10, "blot_style_#{style_num} path should be substantial"
      assert_includes path, "M ", "blot_style_#{style_num} should be valid SVG path"
    end
  end
end
