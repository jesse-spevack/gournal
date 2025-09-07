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
end
