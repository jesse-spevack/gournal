class HabitsController < ApplicationController
  before_action :set_habit, only: [ :update, :destroy ]

  def create
    current_date = Date.current

    # Find the maximum position for the current month's habits
    max_position = Current.user.habits
                          .where(year: current_date.year, month: current_date.month)
                          .maximum(:position) || 0

    # Create the new habit with auto-incremented position
    @habit = Current.user.habits.build(
      name: params[:name],
      year: current_date.year,
      month: current_date.month,
      position: max_position + 1,
      check_type: :x_marks,  # Default to x_marks
      active: true
    )

    if @habit.save
      # Generate HabitEntry for each day of the month using bulk insert to avoid N+1
      days_in_month = Date.new(current_date.year, current_date.month, -1).day
      now = Time.current

      habit_entries_data = (1..days_in_month).map do |day|
        {
          habit_id: @habit.id,
          day: day,
          completed: false,
          checkbox_style: HabitEntry.checkbox_styles.keys.sample,
          check_style: random_check_style_for(@habit.check_type),
          created_at: now,
          updated_at: now
        }
      end

      HabitEntry.insert_all(habit_entries_data)

      redirect_to settings_path, notice: "Habit '#{@habit.name}' added successfully!"
    else
      redirect_to settings_path, alert: "Failed to create habit: #{@habit.errors.full_messages.join(', ')}"
    end
  end

  def update
    # Handle position-only updates (from drag-and-drop AJAX)
    if habit_params.key?(:position) && habit_params.keys == [ "position" ]
      positions_data = [ { "id" => @habit.id, "position" => habit_params[:position] } ]
      result = HabitPositionUpdater.call(user: Current.user, positions: positions_data)

      if result[:success]
        head :ok
      else
        render json: { error: "Failed to update habit position" }, status: :unprocessable_content
      end
    else
      # Handle name updates or mixed updates with redirect
      if habit_params.key?(:position)
        # First update the name, then handle position separately
        name_params = habit_params.except(:position)
        success = name_params.empty? || @habit.update(name_params)

        if success
          positions_data = [ { "id" => @habit.id, "position" => habit_params[:position] } ]
          result = HabitPositionUpdater.call(user: Current.user, positions: positions_data)

          if result[:success]
            redirect_to settings_path, notice: "Habit updated successfully!"
          else
            redirect_to settings_path, alert: "Failed to update habit"
          end
        else
          redirect_to settings_path, alert: "Failed to update habit"
        end
      elsif @habit.update(habit_params)
        redirect_to settings_path, notice: "Habit updated successfully!"
      else
        redirect_to settings_path, alert: "Failed to update habit: #{@habit.errors.full_messages.join(', ')}"
      end
    end
  end

  def destroy
    # Soft delete - set active to false
    if @habit.update(active: false)
      redirect_to settings_path, notice: "Habit removed successfully!"
    else
      redirect_to settings_path, alert: "Failed to remove habit"
    end
  end


  private

  def set_habit
    @habit = Current.user.habits.find(params[:id])
  end

  def habit_params
    params.require(:habit).permit(:name, :position)
  end

  # Replicate the random check style logic from HabitEntry model for bulk inserts
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
