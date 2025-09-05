class SettingsController < ApplicationController
  def index
    @user = Current.user
    current_date = Date.current
    @habits = Current.user.habits
                     .where(year: current_date.year, month: current_date.month, active: true)
                     .order(:position)
  end
end
