class HabitEntriesController < ApplicationController
  allow_unauthenticated_access

  def index
    # Hardcode September 2025 for Phase 2
    # Use environment variable for user email
    user_email = ENV["FIRST_USER"]
    @current_user = User.find_by(email_address: user_email)

    # If user doesn't exist (like in tests), fall back to first user
    @current_user ||= User.first

    @tracker_data = HabitTrackerDataBuilder.call(
      user: @current_user,
      year: 2025,
      month: 9
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
    @tracker_data = HabitTrackerData.new(
      habits: Habit.none,
      habit_entries_lookup: {},
      reflections_lookup: {},
      month_name: "September",
      days_in_month: 30,
      year: 2025,
      month: 9,
      user: nil
    )
  end
end
