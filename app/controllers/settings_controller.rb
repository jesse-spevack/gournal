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
      # Advance onboarding state based on what was updated
      handle_onboarding_progression

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

  def handle_onboarding_progression
    return unless @user.in_onboarding?

    # If slug was just set and user is in habits_created state, advance to profile_created
    if @user.slug.present? && @user.habits_created?
      @user.advance_onboarding_to(:profile_created)
    end

    # If sharing settings were updated and user is in profile_created state, advance to completed
    if (@user.habits_public? || @user.reflections_public?) && @user.profile_created?
      @user.advance_onboarding_to(:completed)
    end
  end
end
