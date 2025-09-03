class HabitPositionUpdater
  def self.call(habit:, new_position:)
    new(habit: habit, new_position: new_position).call
  end

  def initialize(habit:, new_position:)
    @habit = habit
    @new_position = new_position.to_i
  end

  def call
    return true if habit.position == new_position

    Habit.transaction do
      reorder_habits_with_new_position
    end
    true
  rescue => e
    Rails.logger.error "HabitPositionUpdater failed: #{e.message}"
    false
  end

  private

  attr_reader :habit, :new_position

  def reorder_habits_with_new_position
    # First, temporarily move all habits to negative positions to avoid
    # uniqueness constraint conflicts during reorganization
    habits_to_reposition = all_habits_in_scope.to_a

    # Step 1: Move all habits to negative positions temporarily
    habits_to_reposition.each_with_index do |h, index|
      h.update_column(:position, -(index + 1))
    end

    # Step 2: Calculate the new order
    target_habit_index = habits_to_reposition.index(habit)
    habits_to_reposition.delete_at(target_habit_index)

    # Step 3: Assign final positions
    if new_position > habits_to_reposition.length + 1
      # Position beyond range - put at the exact position requested
      habits_to_reposition.each_with_index do |h, index|
        h.update_column(:position, index + 1)
      end
      habit.update_column(:position, new_position)
    else
      # Normal reordering within range
      insert_index = [ new_position - 1, 0 ].max
      insert_index = [ insert_index, habits_to_reposition.length ].min
      habits_to_reposition.insert(insert_index, habit)

      habits_to_reposition.each_with_index do |h, index|
        h.update_column(:position, index + 1)
      end
    end
  end

  def all_habits_in_scope
    @all_habits_in_scope ||= habit.user.habits
                                 .where(year: habit.year, month: habit.month, active: true)
                                 .order(:position)
  end
end
