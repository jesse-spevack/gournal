class OnboardingController < ApplicationController
  def destroy
    Current.user.update!(onboarding_state: :skipped)
    redirect_to settings_path, notice: "Setup skipped. You can access all features normally."
  end
end
