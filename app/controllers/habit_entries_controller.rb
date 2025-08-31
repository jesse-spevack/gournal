class HabitEntriesController < ApplicationController
  def index
    # Hardcode September 2025 for Phase 2
    # Hardcode user jspevack@gmail.com for Phase 2
    @current_user = User.find_by(email_address: "jspevack@gmail.com")

    # If jspevack@gmail.com doesn't exist (like in tests), fall back to first user
    @current_user ||= User.first

    # If no users exist at all, show empty state
    return render_empty_state if @current_user.nil?

    @year = 2025
    @month = 9
    @month_name = Date.new(@year, @month, 1).strftime("%B")

    # Get habits for September 2025, ordered by position
    @habits = Habit.includes(:habit_entries)
                   .where(user: @current_user, year: @year, month: @month)
                   .ordered

    # Get days in September 2025
    @days_in_month = Date.new(@year, @month, -1).day
    @days = (1..@days_in_month).to_a

    # Build a lookup hash for quick access to habit entries
    # Structure: { habit_id => { day => habit_entry } }
    @habit_entries_lookup = {}
    @habits.each do |habit|
      @habit_entries_lookup[habit.id] = {}
      habit.habit_entries.each do |entry|
        @habit_entries_lookup[habit.id][entry.day] = entry
      end
    end
  end

  private

  def render_empty_state
    @month_name = "September"
    @year = 2025
    @habits = []
    @days_in_month = 30
    @habit_entries_lookup = {}
  end
end
