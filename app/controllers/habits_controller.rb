class HabitsController < ApplicationController
  before_action :set_habit, only: [ :update, :destroy ]

  def create
    result = HabitCreator.call(user: Current.user, name: params[:name])

    if result[:success]
      redirect_to settings_path, notice: "Habit '#{result[:habit].name}' added successfully!"
    else
      redirect_to settings_path, alert: "Failed to create habit: #{result[:errors].join(', ')}"
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
end
