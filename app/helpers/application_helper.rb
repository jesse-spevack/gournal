module ApplicationHelper
  def render_habit_checkbox(habit_entry)
    CheckboxRenderer.call(habit_entry: habit_entry, view_context: self)
  end
end
