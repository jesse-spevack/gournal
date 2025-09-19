class HabitEntriesController < ApplicationController
  def index
    @current_user = Current.user

    # Extract year and month from params or use current date
    current_date = Date.current
    year = params[:year]&.to_i || current_date.year
    month = params[:month]&.to_i || current_date.month

    # Validate year and month parameters
    unless valid_date_params?(year, month)
      year = current_date.year
      month = current_date.month
    end

    @tracker_data = HabitTrackerDataBuilder.call(
      user: @current_user,
      year: year,
      month: month
    )

    # Set up navigation paths
    setup_navigation_paths(year, month, current_date)

    # If no user exists, show empty state
    render_empty_state if @current_user.nil?
  end

  def update
    @habit_entry = HabitEntry.find(params[:id])

    # Update the completed status
    if @habit_entry.update(habit_entry_params)
      # For Turbo: respond with no content, no redirect
      head :no_content
    else
      # For Turbo: respond with unprocessable entity
      head :unprocessable_content
    end
  end

  private

  def habit_entry_params
    params.require(:habit_entry).permit(:completed)
  end

  def render_empty_state
    current_date = Date.current
    @tracker_data = HabitTrackerData.new(
      habits: Habit.none,
      habit_entries_lookup: {},
      reflections_lookup: {},
      month_name: current_date.strftime("%B"),
      days_in_month: current_date.end_of_month.day,
      year: current_date.year,
      month: current_date.month,
      user: nil
    )
  end

  def valid_date_params?(year, month)
    return false unless year.is_a?(Integer) && month.is_a?(Integer)
    return false unless year >= 2000 && year <= 2100
    return false unless month >= 1 && month <= 12

    true
  end

  def setup_navigation_paths(year, month, current_date)
    # Find the earliest month with habits for this user
    if @current_user
      earliest_habit = Habit.where(user: @current_user)
                            .order(:year, :month)
                            .first

      # Only show previous month if we're not at the earliest month with habits
      if earliest_habit.nil? || (year > earliest_habit.year) || (year == earliest_habit.year && month > earliest_habit.month)
        prev_date = Date.new(year, month, 1) - 1.month
        @previous_month_path = habit_entries_month_path(year: prev_date.year, month: prev_date.month)
      end
    else
      # No user, show previous month navigation anyway
      prev_date = Date.new(year, month, 1) - 1.month
      @previous_month_path = habit_entries_month_path(year: prev_date.year, month: prev_date.month)
    end

    # Calculate next month (only if not current month)
    @is_current_month = (year == current_date.year && month == current_date.month)
    unless @is_current_month
      next_date = Date.new(year, month, 1) + 1.month
      # Don't allow navigation to future months
      if next_date <= current_date.beginning_of_month
        @next_month_path = habit_entries_month_path(year: next_date.year, month: next_date.month)
      end
    end
  end
end
