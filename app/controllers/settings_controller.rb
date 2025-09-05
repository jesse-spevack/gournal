class SettingsController < ApplicationController
  def index
    @user = Current.user
    current_date = Date.current
    @habits = Current.user.habits
                     .where(year: current_date.year, month: current_date.month, active: true)
                     .order(:position)

    # Check if next month already has habits
    next_month_date = current_date.next_month
    @next_month_habits_exist = Current.user.habits
                                      .where(year: next_month_date.year, month: next_month_date.month, active: true)
                                      .exists?
    @next_month_date = next_month_date
  end
end
