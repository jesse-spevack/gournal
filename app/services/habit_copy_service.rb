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
    previous_habits = find_previous_month_habits
    copy_habits(previous_habits)
  end

  private

  attr_reader :user, :target_year, :target_month

  def find_previous_month_habits
    previous_year, previous_month = calculate_previous_month
    Habit.where(user: user, year: previous_year, month: previous_month)
  end

  def calculate_previous_month
    if target_month == 1
      [ target_year - 1, 12 ]
    else
      [ target_year, target_month - 1 ]
    end
  end

  def copy_habits(habits)
    habits.map do |habit|
      copied_habit = habit.dup
      copied_habit.assign_attributes(year: target_year, month: target_month)
      copied_habit.save!
      HabitEntryCreator.call(habit: copied_habit)
      copied_habit
    end
  end
end
