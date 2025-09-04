class HabitPositionUpdater
  def self.call(user:, positions:)
    new(user: user, positions: positions).call
  end

  def initialize(user:, positions:)
    @user = user
    @positions = positions
  end

  def call
    return { success: false, error: "Invalid positions data" } unless valid_positions_data?

    Habit.transaction do
      # Get current date for scope
      current_date = Date.current

      # Get all habits in scope
      habits_scope = @user.habits
                          .where(year: current_date.year, month: current_date.month, active: true)

      # Step 1: Move all habits to negative positions to avoid uniqueness conflicts
      habits_scope.each_with_index do |habit, index|
        habit.update_column(:position, -(index + 1))
      end

      # Step 2: Apply the new positions from the request
      @positions.each do |position_data|
        habit_id = position_data["id"] || position_data[:id]
        new_position = position_data["position"] || position_data[:position]

        next unless habit_id && new_position

        habit = habits_scope.find_by(id: habit_id)
        next unless habit

        habit.update_column(:position, new_position.to_i)
      end

      { success: true }
    end
  rescue => e
    Rails.logger.error "HabitPositionUpdater failed: #{e.message}"
    { success: false, error: "Failed to update positions" }
  end

  private

  def valid_positions_data?
    return false unless @positions.is_a?(Array)
    return false if @positions.empty?

    @positions.all? do |item|
      (item["id"] || item[:id]) && (item["position"] || item[:position])
    end
  end
end
