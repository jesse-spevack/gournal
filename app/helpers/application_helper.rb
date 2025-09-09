module ApplicationHelper
  def render_habit_checkbox(habit_entry)
    CheckboxRenderer.call(habit_entry: habit_entry, view_context: self)
  end

  def render_public_habit_checkbox(habit_entry)
    content_tag(:div, class: "checkbox-container") do
      # Extract the randomized style numbers from the stored enum values
      box_number = habit_entry.checkbox_style.split("_").last
      check_number = habit_entry.check_style.split("_").last

      if !habit_entry&.completed?
        render("checkboxes/box_#{box_number}")
      elsif habit_entry.habit.x_marks?
        render("checkboxes/box_#{box_number}") + render("checkboxes/x_#{check_number}")
      else
        render("checkboxes/box_#{box_number}") + render("checkboxes/blot_#{check_number}")
      end
    end
  end

  # Format date as "Month Year" (e.g., "October 2024")
  def format_month_year(year, month = nil)
    if year.respond_to?(:strftime)
      # Handle Date/DateTime objects
      year.strftime("%B %Y")
    elsif month
      # Handle separate year and month integers
      Date.new(year, month, 1).strftime("%B %Y")
    else
      # year must be a Date-like object if month is nil
      raise ArgumentError, "Invalid arguments: expected Date object or year/month integers"
    end
  end

  # Format date as month name only (e.g., "October")
  def format_month_name(year, month = nil)
    if year.respond_to?(:strftime)
      # Handle Date/DateTime objects
      year.strftime("%B")
    elsif month
      # Handle separate year and month integers
      Date.new(year, month, 1).strftime("%B")
    else
      # year must be a Date-like object if month is nil
      raise ArgumentError, "Invalid arguments: expected Date object or year/month integers"
    end
  end

  # Format date as "Month DD, YYYY" (e.g., "October 15, 2024")
  def format_full_date(date)
    date.strftime("%B %d, %Y")
  end

  # Format as YYYY-MM string for URL parameters (e.g., "2024-10")
  def format_year_month_param(year, month = nil)
    if year.respond_to?(:strftime)
      # Handle Date/DateTime objects
      year.strftime("%Y-%m")
    elsif month
      # Handle separate year and month integers
      "#{year}-#{month.to_s.rjust(2, '0')}"
    else
      # year must be a Date-like object if month is nil
      raise ArgumentError, "Invalid arguments: expected Date object or year/month integers"
    end
  end
end
