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
    result = HabitCreator.call(user: Current.user, name: params[:name])

    if result[:success]
      redirect_to settings_path
    else
      redirect_to settings_path
    end
  end

  def update
    if @habit.update(habit_params)
      redirect_to settings_path
    else
      redirect_to settings_path
    end
  end

  def destroy
    # Soft delete - set active to false
    if @habit.update(active: false)
      redirect_to settings_path
    else
      redirect_to settings_path
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
