class MonthSetupsController < ApplicationController
  before_action :require_authentication
  include ApplicationHelper

  def create
    strategy = params[:strategy]
    target_year = params[:target_year]&.to_i
    target_month = params[:target_month]&.to_i

    if strategy == "copy"
      HabitCopyService.call(
        user: Current.user,
        target_year: target_year,
        target_month: target_month
      )
      redirect_to habit_entries_path(year: target_year, month: target_month)
    elsif strategy == "fresh"
      redirect_to new_habit_path(year_month: format_year_month_param(target_year, target_month))
    else
      redirect_to settings_path
    end
  end
end
