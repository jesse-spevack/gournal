class HabitCopyService
  def self.call(user:, target_year:, target_month:)
    new(user: user, target_year: target_year, target_month: target_month).call
  end

  def initialize(user:, target_year:, target_month:)
    @user = user
    @target_year = target_year
    @target_month = target_month
  end

  def call
    # Find habits from previous month
    previous_habits = find_previous_month_habits

    return { success: false, error: no_habits_message, count: 0 } if previous_habits.empty?

    # Check if copying would exceed limit
    current_habit_count = current_month_habit_count
    total_after_copy = current_habit_count + previous_habits.count

    if total_after_copy > HABIT_LIMIT
      return {
        success: false,
        error: "Cannot copy habits - would exceed maximum limit of #{HABIT_LIMIT} habits per month.",
        count: 0
      }
    end

    # Copy the habits
    copied_count = copy_habits(previous_habits)

    {
      success: true,
      message: success_message(copied_count),
      count: copied_count
    }
  end

  private

  HABIT_LIMIT = Habit::MAX_HABITS_PER_MONTH

  def previous_month_date
    @previous_month_date ||= Date.new(@target_year, @target_month).prev_month
  end

  def find_previous_month_habits
    @user.habits.current_month(previous_month_date.year, previous_month_date.month).ordered
  end

  def current_month_habit_count
    @user.habits.current_month(@target_year, @target_month).count
  end

  def copy_habits(previous_habits)
    starting_position = find_next_available_position

    previous_habits.map.with_index do |habit, index|
      create_habit_copy(habit, starting_position + index)
    end.count(&:persisted?)
  end

  def create_habit_copy(original_habit, position)
    @user.habits.create!(
      name: original_habit.name,
      month: @target_month,
      year: @target_year,
      position: position,
      check_type: original_habit.check_type,
      active: original_habit.active
    )
  end

  def find_next_available_position
    @user.habits.current_month(@target_year, @target_month).maximum(:position).to_i + 1
  end

  def no_habits_message
    "No habits found to copy from #{previous_month_date.strftime('%B %Y')}."
  end

  def success_message(count)
    "#{count} #{count == 1 ? 'habit' : 'habits'} copied from #{previous_month_date.strftime('%B %Y')}."
  end
end
