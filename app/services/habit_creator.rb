class HabitCreator
  def self.call(user:, name:, year: nil, month: nil)
    new(user: user, name: name, year: year, month: month).call
  end

  def initialize(user:, name:, year: nil, month: nil)
    @user = user
    @name = name
    @target_date = if year && month
                     Date.new(year.to_i, month.to_i, 1)
    else
                     Date.current
    end
  end

  def call
    max_position = @user.habits
                        .where(year: @target_date.year, month: @target_date.month)
                        .maximum(:position) || 0

    habit = @user.habits.build(
      name: @name,
      year: @target_date.year,
      month: @target_date.month,
      position: max_position + 1,
      check_type: :x_marks,
      active: true
    )

    if habit.save
      HabitEntryCreator.call(habit: habit, year: @target_date.year, month: @target_date.month)
      { success: true, habit: habit }
    else
      { success: false, errors: habit.errors.full_messages }
    end
  end
end
