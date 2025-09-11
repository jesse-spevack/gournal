class SettingsController < ApplicationController
  def index
    @user = Current.user
    @onboarding_state = @user.onboarding_state
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

  def update
    @user = Current.user

    if @user.update(user_params)
      redirect_to settings_path, notice: "Profile settings updated successfully"
    else
      # Re-render index with errors
      @onboarding_state = @user.onboarding_state
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

      render :index, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.require(:user).permit(:slug, :habits_public, :reflections_public)
  end
end
