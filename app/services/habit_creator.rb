class HabitCreator
  def self.call(user:, name:)
    new(user: user, name: name).call
  end

  def initialize(user:, name:)
    @user = user
    @name = name
  end

  def call
    current_date = Date.current

    max_position = @user.habits
                        .where(year: current_date.year, month: current_date.month)
                        .maximum(:position) || 0

    habit = @user.habits.build(
      name: @name,
      year: current_date.year,
      month: current_date.month,
      position: max_position + 1,
      check_type: :x_marks,
      active: true
    )

    if habit.save
      create_habit_entries(habit, current_date)
      { success: true, habit: habit }
    else
      { success: false, errors: habit.errors.full_messages }
    end
  end

  private

  def create_habit_entries(habit, current_date)
    days_in_month = Date.new(current_date.year, current_date.month, -1).day
    now = Time.current

    habit_entries_data = (1..days_in_month).map do |day|
      {
        habit_id: habit.id,
        day: day,
        completed: false,
        checkbox_style: HabitEntry.checkbox_styles.keys.sample,
        check_style: random_check_style_for(habit.check_type),
        created_at: now,
        updated_at: now
      }
    end

    HabitEntry.insert_all(habit_entries_data)
  end

  def random_check_style_for(check_type)
    case check_type
    when "x_marks"
      HabitEntry.check_styles.keys.select { |k| k.start_with?("x_style_") }.sample
    when "blots"
      HabitEntry.check_styles.keys.select { |k| k.start_with?("blot_style_") }.sample
    else
      HabitEntry.check_styles.keys.sample
    end
  end
end
