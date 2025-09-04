class Habits::PositionsController < ApplicationController
  def update
    habit_positions = params.require(:positions)

    # Use the refactored HabitPositionUpdater for batch updates
    result = HabitPositionUpdater.call(
      user: Current.user,
      positions: habit_positions
    )

    if result[:success]
      head :ok
    else
      render json: { error: result[:error] }, status: :unprocessable_content
    end
  end
end
