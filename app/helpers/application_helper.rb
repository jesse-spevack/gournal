module ApplicationHelper
  def render_habit_checkbox(habit_entry)
    # Get the box and X style numbers from the enums
    box_style_number = habit_entry.checkbox_style.split("_").last
    check_style_number = habit_entry.check_style.split("_").last

    # Wrap everything in a form for submission
    form_with model: habit_entry, url: habit_entry_path(habit_entry),
              method: :patch, local: false, class: "checkbox-form" do |form|
      # Use the exact working pattern from style guide
      content_tag :label, class: "checkbox-wrapper",
                  data: {
                    controller: "checkbox",
                    checkbox_checked_class: "checkbox-checked",
                    checkbox_unchecked_class: "checkbox-unchecked",
                    checkbox_x_visible_class: "x-visible"
                  },
                  style: "cursor: pointer;" do
        # Hidden checkbox input for form submission
        checkbox_input = form.check_box :completed,
                                       {
                                         checked: habit_entry.completed?,
                                         data: {
                                           checkbox_target: "input",
                                           action: "change->checkbox#toggle"
                                         },
                                         style: "position: absolute; opacity: 0; cursor: pointer; height: 0; width: 0;",
                                         onchange: "this.form.submit();"
                                       },
                                       "true", "false"

        # Custom SVG checkbox display
        custom_checkbox = content_tag :div, class: "checkbox-custom" do
          # Box component - render the partial directly
          box_html = content_tag :div, class: "checkbox-box",
                                 data: { checkbox_target: "boxPath" } do
            # Add the checked/unchecked class to the wrapper div
            box_partial = render("checkboxes/box_#{box_style_number}")
            # Apply the class based on completed state
            if habit_entry.completed?
              box_partial.gsub('class="box-path"', 'class="box-path checkbox-checked"')
            else
              box_partial.gsub('class="box-path"', 'class="box-path checkbox-unchecked"')
            end.html_safe
          end

          # X mark component - render the partial directly
          x_mark_html = content_tag :div, class: "x-marks-container" do
            x_mark_class = habit_entry.completed? ? "x-mark x-visible" : "x-mark"
            content_tag :div, class: x_mark_class, data: { checkbox_target: "xMark" } do
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
