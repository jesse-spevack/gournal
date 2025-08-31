class CheckboxRenderer
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  def self.call(habit_entry:, view_context:)
    new(habit_entry: habit_entry, view_context: view_context).call
  end

  def initialize(habit_entry:, view_context:)
    @habit_entry = habit_entry
    @view_context = view_context
  end

  def call
    return empty_checkbox unless @habit_entry

    @view_context.form_with model: @habit_entry,
                            url: @view_context.habit_entry_path(@habit_entry),
                            method: :patch,
                            local: false,
                            class: "checkbox-form" do |form|
      build_checkbox_wrapper(form)
    end
  end

  private

  attr_reader :habit_entry, :view_context

  def build_checkbox_wrapper(form)
    content_tag :label, checkbox_wrapper_options do
      safe_join([
        build_checkbox_input(form),
        build_custom_checkbox
      ])
    end
  end

  def checkbox_wrapper_options
    {
      class: "checkbox-wrapper",
      data: {
        controller: "checkbox",
        checkbox_checked_class: "checkbox-checked",
        checkbox_unchecked_class: "checkbox-unchecked",
        checkbox_x_visible_class: "x-visible"
      },
      style: "cursor: pointer;"
    }
  end

  def build_checkbox_input(form)
    form.check_box :completed,
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
  end

  def build_custom_checkbox
    content_tag :div, class: "checkbox-custom" do
      safe_join([ render_checkbox_box, render_x_mark ])
    end
  end

  def render_checkbox_box
    content_tag :div, class: "checkbox-box",
                     data: { checkbox_target: "boxPath" } do
      box_number = extract_box_number
      box_classes = habit_entry.completed? ?
        "box-path checkbox-checked" :
        "box-path checkbox-unchecked"

      # Render partial with classes passed as locals
      @view_context.render partial: "checkboxes/box_#{box_number}",
                          locals: { path_classes: box_classes }
    end
  end

  def render_x_mark
    content_tag :div, class: "x-marks-container" do
      x_mark_class = habit_entry.completed? ? "x-mark x-visible" : "x-mark"
      content_tag :div, class: x_mark_class, data: { checkbox_target: "xMark" } do
        x_number = extract_x_number
        @view_context.render partial: "checkboxes/x_#{x_number}"
      end
    end
  end

  def extract_box_number
    habit_entry.checkbox_style.split("_").last
  end

  def extract_x_number
    habit_entry.check_style.split("_").last
  end

  def empty_checkbox
    content_tag :div, "", class: "checkbox-placeholder"
  end
end
