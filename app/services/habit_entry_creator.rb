class HabitEntryCreator
  def self.call(habit:, year:, month:)
    new(habit: habit, year: year, month: month).call
  end

  def initialize(habit:, year:, month:)
    @habit = habit
    @year = year
    @month = month
  end

  def call
    create_entries_for_month
  end

  private

  attr_reader :habit, :year, :month

  def create_entries_for_month
    days_in_month = Date.new(year, month, -1).day
    now = Time.current

    habit_entries_data = (1..days_in_month).map do |day|
      {
        habit_id: habit.id,
        day: day,
        completed: false,
        checkbox_style: random_checkbox_style,
        check_style: random_check_style,
        created_at: now,
        updated_at: now
      }
    end

    HabitEntry.insert_all(habit_entries_data) if habit_entries_data.any?
  end

  def random_checkbox_style
    HabitEntry.checkbox_styles.keys.sample
  end

  def random_check_style
    case habit.check_type
    when "x_marks"
      HabitEntry.check_styles.keys.select { |k| k.start_with?("x_style_") }.sample
    when "blots"
      HabitEntry.check_styles.keys.select { |k| k.start_with?("blot_style_") }.sample
    else
      HabitEntry.check_styles.keys.sample
    end
  end
end
