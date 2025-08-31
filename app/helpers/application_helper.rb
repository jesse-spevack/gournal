module ApplicationHelper
  def render_habit_checkbox(habit_entry)
    # Get the box style number from the enum (e.g., "box_style_3" -> 3)
    box_style_number = habit_entry.checkbox_style.split("_").last

    # Get the check style number from the enum (e.g., "x_style_7" -> 7)
    check_style_number = habit_entry.check_style.split("_").last

    # Render the checkbox with Turbo form for updating completion status
    content_tag :div, class: "checkbox-wrapper", data: { controller: "checkbox" } do
      form_with model: habit_entry, url: habit_entry_path(habit_entry),
                method: :patch, local: false, class: "checkbox-form" do |form|
        # Hidden checkbox input for form submission
        checkbox_input = form.check_box :completed,
                                       { class: "checkbox-input",
                                         data: {
                                           checkbox_target: "input",
                                           action: "change->checkbox#toggle"
                                         } },
                                       "true", "false"

        # Custom SVG checkbox display
        custom_checkbox = content_tag :span, class: "checkbox-custom" do
          # Box component
          box_html = render "checkboxes/box_#{box_style_number}"

          # X mark component (conditionally shown)
          x_mark_html = content_tag :span, class: "x-marks-container" do
            x_mark_class = habit_entry.completed? ? "x-mark show" : "x-mark"
            content_tag :span, class: x_mark_class, data: { checkbox_target: "xMark" } do
              render "checkboxes/x_#{check_style_number}"
            end
          end

          box_html + x_mark_html
        end

        checkbox_input + custom_checkbox
      end
    end
  end
end
