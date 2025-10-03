class Habits::PositionsController < ApplicationController
  def update
    habit_positions = params.require(:positions)
    target_year = params[:target_year]&.to_i
    target_month = params[:target_month]&.to_i

    result = HabitPositionUpdater.call(
      user: Current.user,
      positions: habit_positions,
      year: target_year,
      month: target_month
    )

    if result[:success]
      head :ok
    else
      render json: { error: result[:error] }, status: :unprocessable_content
    end
  end
end
