class HabitTrackerDataBuilder
  def self.call(user:, year: Date.current.year, month: Date.current.month)
    new(user: user, year: year, month: month).call
  end

  def initialize(user:, year:, month:)
    raise ArgumentError, "User cannot be nil" if user.nil?

    @user = user
    @year = year
    @month = month
  end

  def call
    HabitTrackerData.new(
      habits: fetch_habits,
      habit_entries_lookup: build_entries_lookup,
      reflections_lookup: build_reflections_lookup,
      month_name: month_name,
      days_in_month: days_in_month,
      year: @year,
      month: @month,
      user: @user
    )
  end

  private

  def fetch_habits
    @habits ||= @user.habits
      .includes(:habit_entries)
      .where(year: @year, month: @month, active: true)
      .ordered
  end

  def build_entries_lookup
    lookup = {}
    fetch_habits.each do |habit|
      habit.habit_entries.each do |entry|
        lookup[[ habit.id, entry.day ]] = entry
      end
    end
    lookup
  end

  def build_reflections_lookup
    lookup = {}
    reflections = @user.daily_reflections.for_month(@year, @month)
    reflections.each do |reflection|
      lookup[reflection.date.day] = reflection
    end
    lookup
  end

  def month_name
    Date.new(@year, @month, 1).strftime("%B")
  end

  def days_in_month
    Date.new(@year, @month, -1).day
  end
end
