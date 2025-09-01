class HabitTrackerData
  attr_reader :habits, :habit_entries_lookup, :reflections_lookup, :month_name,
              :days_in_month, :year, :month, :user

  def initialize(habits:, habit_entries_lookup:, reflections_lookup:, month_name:,
                 days_in_month:, year:, month:, user:)
    @habits = habits
    @habit_entries_lookup = habit_entries_lookup
    @reflections_lookup = reflections_lookup
    @month_name = month_name
    @days_in_month = days_in_month
    @year = year
    @month = month
    @user = user
  end

  def habit_entry_for(habit_id, day)
    @habit_entries_lookup[[ habit_id, day ]]
  end

  def reflection_for(day)
    @reflections_lookup[day]
  end

  def empty?
    @habits.empty?
  end

  def days
    @days ||= (1..@days_in_month).to_a
  end
end
