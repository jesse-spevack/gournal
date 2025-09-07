class HabitsController < ApplicationController
  before_action :set_habit, only: [ :update, :destroy ]
  include ApplicationHelper

  def new
    @year_month = params[:year_month] || format_year_month_param(Date.current)
    year, month = @year_month.split("-").map(&:to_i)
    @target_year = year
    @target_month = month
    @habits = Current.user.habits.where(year: year, month: month, active: true).order(:position)
  end

  def create
    # Extract year and month from year_month parameter if available
    year_month = params[:year_month]
    target_year, target_month = if year_month.present?
                                  year_month.split("-").map(&:to_i)
    else
                                  [ nil, nil ]
    end

    result = HabitCreator.call(
      user: Current.user,
      name: params[:name],
      year: target_year,
      month: target_month
    )

    respond_to do |format|
      if result[:success]
        format.html do
          # Redirect back to the habit creation page to stay in the flow
          if year_month.present?
            redirect_to new_habit_path(year_month: year_month)
          else
            redirect_to settings_path
          end
        end
        format.json { render json: { success: true, habit: result[:habit] } }
      else
        format.html do
          # Redirect back to the habit creation page to stay in the flow
          if year_month.present?
            redirect_to new_habit_path(year_month: year_month)
          else
            redirect_to settings_path
          end
        end
        format.json { render json: { success: false, errors: result[:errors] }, status: :unprocessable_content }
      end
    end
  end

  def update
    respond_to do |format|
      if @habit.update(habit_params)
        format.html { redirect_to settings_path }
        format.json { render json: { success: true, habit: @habit } }
      else
        format.html { redirect_to settings_path }
        format.json { render json: { success: false, errors: @habit.errors }, status: :unprocessable_content }
      end
    end
  end

  def destroy
    # Soft delete - set active to false
    respond_to do |format|
      if @habit.update(active: false)
        format.html { redirect_to settings_path }
        format.json { render json: { success: true } }
      else
        format.html { redirect_to settings_path }
        format.json { render json: { success: false, errors: @habit.errors }, status: :unprocessable_content }
      end
    end
  end


  private

  def set_habit
    @habit = Current.user.habits.find(params[:id])
  end

  def habit_params
    params.require(:habit).permit(:name)
  end
end
