class HabitEntryCreator
  def self.call(habit:)
    new(habit: habit).call
  end

  def initialize(habit:)
    raise ArgumentError, "Habit cannot be nil" if habit.nil?

    @habit = habit
  end

  def call
    create_entries_for_month
  end

  private

  attr_reader :habit

  def create_entries_for_month
    days_in_month = Time.days_in_month(habit.month, habit.year)
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

    HabitEntry.insert_all(habit_entries_data)
  end

  def random_checkbox_style
    HabitEntryStyleSelector.random_checkbox_style
  end

  def random_check_style
    HabitEntryStyleSelector.random_check_style_for(habit.check_type)
  end
end
