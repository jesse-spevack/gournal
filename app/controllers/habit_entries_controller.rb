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

    # Generate ETag and Last-Modified for caching based on habit data
    if @current_user
      last_modified = calculate_last_modified(year, month)
      etag = ETagGenerator.call(user: @current_user, year: year, month: month, last_modified: last_modified)
      fresh_when(etag: etag, last_modified: last_modified)
    end

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
      if earliest_habit.nil? || after_date?(year, month, earliest_habit.year, earliest_habit.month)
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

  def after_date?(year1, month1, year2, month2)
    year1 > year2 || (year1 == year2 && month1 > month2)
  end

  def calculate_last_modified(year, month)
    # Find the most recent timestamp from habits and habit entries for this user/month
    habits_timestamp = @current_user.habits
      .where(year: year, month: month, active: true)
      .maximum(:updated_at)

    habit_ids = @current_user.habits
      .where(year: year, month: month, active: true)
      .pluck(:id)

    entries_timestamp = if habit_ids.any?
      HabitEntry.where(habit_id: habit_ids).maximum(:updated_at)
    end

    # Return the most recent timestamp, or a default based on the specific month if no data exists
    most_recent = [ habits_timestamp, entries_timestamp ].compact.max

    # Use a consistent fallback timestamp based on the month being requested
    # instead of Time.current which changes during test execution
    most_recent || Time.zone.local(year, month, 1).beginning_of_month
  end
end
