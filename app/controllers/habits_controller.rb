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
    if position_only_update?
      handle_position_update
    else
      handle_name_update
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

  def position_only_update?
    habit_params.key?(:position) && habit_params.keys == [ "position" ]
  end

  def handle_position_update
    positions_data = [ { "id" => @habit.id, "position" => habit_params[:position] } ]
    result = HabitPositionUpdater.call(user: Current.user, positions: positions_data)

    if result[:success]
      head :ok
    else
      render json: { error: "Failed to update habit position" }, status: :unprocessable_content
    end
  end

  def handle_name_update
    if @habit.update(habit_params)
      redirect_to settings_path, notice: "Habit updated successfully!"
    else
      redirect_to settings_path, alert: "Failed to update habit: #{@habit.errors.full_messages.join(', ')}"
    end
  end
end
