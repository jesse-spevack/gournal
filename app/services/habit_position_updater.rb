class HabitPositionUpdater
  def self.call(user:, positions:)
    new(user: user, positions: positions).call
  end

  def initialize(user:, positions:)
    @user = user
    @positions = positions
  end

  def call
    return validation_error unless valid_positions_data?

    begin
      update_positions_in_transaction
      { success: true }
    rescue => e
      handle_update_error(e)
    end
  end

  private

  def validation_error
    { success: false, error: "Invalid positions data" }
  end

  def update_positions_in_transaction
    Habit.transaction do
      reset_positions_to_negative
      apply_new_positions
    end
  end

  def reset_positions_to_negative
    habits_scope.each_with_index do |habit, index|
      habit.update_column(:position, -(index + 1))
    end
  end

  def apply_new_positions
    normalized_positions.each do |position_data|
      update_single_habit_position(position_data)
    end
  end

  def update_single_habit_position(position_data)
    habit = find_habit_by_id(position_data[:id])
    return unless habit && !position_data[:position].nil?

    habit.update_column(:position, position_data[:position].to_i)
  end

  def find_habit_by_id(habit_id)
    habits_scope.find_by(id: habit_id)
  end

  def habits_scope
    @habits_scope ||= begin
      current_date = Date.current
      @user.habits.where(year: current_date.year, month: current_date.month, active: true)
    end
  end

  def normalized_positions
    @normalized_positions ||= @positions.map do |item|
      {
        id: (item["id"] || item[:id]),
        position: (item["position"] || item[:position])
      }
    end
  end

  def valid_positions_data?
    return false unless @positions.is_a?(Array)
    return false if @positions.empty?

    normalized_positions.all? { |item| item[:id] && !item[:position].nil? }
  end

  def handle_update_error(error)
    Rails.logger.error "HabitPositionUpdater failed: #{error.message}"
    { success: false, error: "Failed to update positions" }
  end
end
