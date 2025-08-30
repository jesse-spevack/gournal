require "test_helper"

class SvgCheckboxRendererTest < ActiveSupport::TestCase
  def setup
    @renderer = SvgCheckboxRenderer.new
  end

  test "generates SVG checkbox with box path only when unchecked" do
    svg = @renderer.render(
      box_path: "M 3,3 L 21,3 L 21,21 L 3,21 Z",
      checked: false
    )

    assert_includes svg, "<svg"
    assert_includes svg, 'viewBox="0 0 24 24"'
    assert_includes svg, "M 3,3 L 21,3 L 21,21 L 3,21 Z"
    assert_includes svg, 'class="checkbox__box-path"'
    refute_includes svg, 'class="checkbox__mark"'
    refute_includes svg, 'class="checkbox__fill"'
  end

  test "generates SVG checkbox with box path and X mark when checked with x_style" do
    svg = @renderer.render(
      box_path: "M 3,3 L 21,3 L 21,21 L 3,21 Z",
      check_path: "M 6,6 L 18,18 M 18,6 L 6,18",
      check_type: :x_mark,
      checked: true
    )

    assert_includes svg, "<svg"
    assert_includes svg, "M 3,3 L 21,3 L 21,21 L 3,21 Z"
    assert_includes svg, "M 6,6 L 18,18 M 18,6 L 6,18"
    assert_includes svg, 'class="checkbox__box-path"'
    assert_includes svg, 'class="checkbox__x-path"'
    refute_includes svg, 'class="checkbox__fill"'
  end

  test "generates SVG checkbox with box path and blot fill when checked with blot_style" do
    svg = @renderer.render(
      box_path: "M 3,3 L 21,3 L 21,21 L 3,21 Z",
      check_path: "M 4,6 C 6,5 8,5 12,6 C 16,7 20,8 20,12 C 20,16 16,19 12,19 C 8,19 4,16 4,12 Z",
      check_type: :blot,
      checked: true
    )

    assert_includes svg, "<svg"
    assert_includes svg, "M 3,3 L 21,3 L 21,21 L 3,21 Z"
    assert_includes svg, "M 4,6 C 6,5 8,5 12,6 C 16,7 20,8 20,12 C 20,16 16,19 12,19 C 8,19 4,16 4,12 Z"
    assert_includes svg, 'class="checkbox__box-path"'
    assert_includes svg, 'class="checkbox__fill"'
    refute_includes svg, 'class="checkbox__x-path"'
  end

  test "applies CSS classes correctly for different checkbox states" do
    unchecked_svg = @renderer.render(
      box_path: "M 3,3 L 21,3 L 21,21 L 3,21 Z",
      checked: false
    )

    checked_svg = @renderer.render(
      box_path: "M 3,3 L 21,3 L 21,21 L 3,21 Z",
      check_path: "M 6,6 L 18,18 M 18,6 L 6,18",
      check_type: :x_mark,
      checked: true
    )

    assert_includes unchecked_svg, 'class="checkbox__box"'
    assert_includes checked_svg, 'class="checkbox__box"'
    assert_includes checked_svg, 'class="checkbox__mark"'
  end

  test "handles custom CSS classes" do
    svg = @renderer.render(
      box_path: "M 3,3 L 21,3 L 21,21 L 3,21 Z",
      css_class: "custom-checkbox",
      checked: false
    )

    assert_includes svg, 'class="custom-checkbox"'
  end

  test "raises error for missing box_path" do
    assert_raises(ArgumentError, "box_path is required") do
      @renderer.render(checked: false)
    end
  end

  test "raises error for checked checkbox without check_path" do
    assert_raises(ArgumentError, "check_path is required when checked is true") do
      @renderer.render(
        box_path: "M 3,3 L 21,3 L 21,21 L 3,21 Z",
        checked: true
      )
    end
  end

  test "raises error for checked checkbox without check_type" do
    assert_raises(ArgumentError, "check_type is required when checked is true") do
      @renderer.render(
        box_path: "M 3,3 L 21,3 L 21,21 L 3,21 Z",
        check_path: "M 6,6 L 18,18",
        checked: true
      )
    end
  end

  test "validates check_type values" do
    assert_raises(ArgumentError, "check_type must be :x_mark or :blot") do
      @renderer.render(
        box_path: "M 3,3 L 21,3 L 21,21 L 3,21 Z",
        check_path: "M 6,6 L 18,18",
        check_type: :invalid,
        checked: true
      )
    end
  end

  test "generates different SVG output for different box paths" do
    svg1 = @renderer.render(
      box_path: "M 3,3 L 21,3 L 21,21 L 3,21 Z",
      checked: false
    )

    svg2 = @renderer.render(
      box_path: "M 2,4 C 2,2 4,2 6,2 L 18,2 C 20,2 22,2 22,4 L 22,20 C 22,22 20,22 18,22 L 6,22 C 4,22 2,22 2,20 Z",
      checked: false
    )

    refute_equal svg1, svg2
    assert_includes svg1, "M 3,3 L 21,3 L 21,21 L 3,21 Z"
    assert_includes svg2, "M 2,4 C 2,2 4,2 6,2 L 18,2 C 20,2 22,2 22,4 L 22,20 C 22,22 20,22 18,22 L 6,22 C 4,22 2,22 2,20 Z"
  end

  test "generates different SVG output for different check paths" do
    svg1 = @renderer.render(
      box_path: "M 3,3 L 21,3 L 21,21 L 3,21 Z",
      check_path: "M 6,6 L 18,18 M 18,6 L 6,18",
      check_type: :x_mark,
      checked: true
    )

    svg2 = @renderer.render(
      box_path: "M 3,3 L 21,3 L 21,21 L 3,21 Z",
      check_path: "M 7,7 L 17,17 M 17,7 L 7,17",
      check_type: :x_mark,
      checked: true
    )

    refute_equal svg1, svg2
    assert_includes svg1, "M 6,6 L 18,18 M 18,6 L 6,18"
    assert_includes svg2, "M 7,7 L 17,17 M 17,7 L 7,17"
  end
end
