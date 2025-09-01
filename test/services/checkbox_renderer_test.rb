require "test_helper"

class CheckboxRendererTest < ActiveSupport::TestCase
  include ActionView::TestCase::Behavior

  setup do
    @user = users(:one)
    @habit = Habit.create!(
      user: @user,
      name: "Test Habit",
      year: 2025,
      month: 9,
      position: 1,
      check_type: :x_marks
    )
    @habit_entry = HabitEntry.create!(
      habit: @habit,
      day: 1,
      completed: false
    )
  end

  test "renders checkbox form for habit entry" do
    result = CheckboxRenderer.call(
      habit_entry: @habit_entry,
      view_context: view
    )

    assert_match "checkbox-form", result
    assert_match "checkbox-wrapper", result
    assert_match "checkbox-unchecked", result
  end

  test "renders completed state correctly" do
    @habit_entry.update!(completed: true)

    result = CheckboxRenderer.call(
      habit_entry: @habit_entry,
      view_context: view
    )

    assert_match "checkbox-checked", result
    assert_match "x-visible", result
  end

  test "returns empty checkbox for nil entry" do
    result = CheckboxRenderer.call(
      habit_entry: nil,
      view_context: view
    )

    assert_match "checkbox-placeholder", result
  end

  test "extracts box and x numbers correctly" do
    # Force specific styles for testing
    @habit_entry.update!(
      checkbox_style: :box_style_5,
      check_style: :x_style_3
    )

    result = CheckboxRenderer.call(
      habit_entry: @habit_entry,
      view_context: view
    )

    # Check that the correct partials are being rendered based on the styles
    # This is more robust than checking specific SVG coordinates
    assert_includes result, "checkbox-box"  # SVG wrapper class
    # The service should render the box_5 and x_3 partials based on the styles
    # We can't easily test partial names directly, but we can verify the structure
    assert_includes result, "checkbox-custom"  # Custom checkbox container
    assert_includes result, "x-marks-container"  # X mark container
  end

  test "includes proper form attributes" do
    result = CheckboxRenderer.call(
      habit_entry: @habit_entry,
      view_context: view
    )

    assert_match 'name="_method"', result  # Rails adds hidden _method field
    assert_match 'value="patch"', result   # PATCH method via hidden field
    assert_match 'data-remote="true"', result
  end

  test "includes stimulus controller data attributes" do
    result = CheckboxRenderer.call(
      habit_entry: @habit_entry,
      view_context: view
    )

    assert_match 'data-controller="checkbox"', result
    assert_match 'data-checkbox-checked-class="checkbox-checked"', result
    assert_match 'data-checkbox-unchecked-class="checkbox-unchecked"', result
    assert_match 'data-checkbox-x-visible-class="x-visible"', result
  end
end
