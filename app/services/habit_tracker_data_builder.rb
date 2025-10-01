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
    habits = @user.habits
      .includes(:habit_entries)
      .where(year: @year, month: @month, active: true)
      .ordered

    ensure_habit_entries_exist(habits)

    @habits ||= habits
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

  def ensure_habit_entries_exist(habits)
    return if habits.empty?

    entries_created = false

    habits.each do |habit|
      existing_days = habit.habit_entries.map(&:day).to_set
      missing_days = (1..days_in_month).to_a - existing_days.to_a

      if missing_days.any?
        create_missing_entries(habit, missing_days)
        entries_created = true
      end
    end

    habits.each(&:reload) if entries_created
  end

  def create_missing_entries(habit, missing_days)
    now = Time.current

    entries_data = missing_days.map do |day|
      {
        habit_id: habit.id,
        day: day,
        completed: false,
        checkbox_style: HabitEntryStyleSelector.random_checkbox_style,
        check_style: random_check_style_for_habit(habit),
        created_at: now,
        updated_at: now
      }
    end

    HabitEntry.insert_all(entries_data) if entries_data.any?
  end

  def random_check_style_for_habit(habit)
    HabitEntryStyleSelector.random_check_style_for(habit.check_type)
  end
end
