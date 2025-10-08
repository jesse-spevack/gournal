class TimezoneController < ApplicationController
  allow_unauthenticated_access

  def create
    timezone = params[:timezone]

    if ActiveSupport::TimeZone::MAPPING.value?(timezone)
      session[:user_timezone] = timezone
      cookies[:tz] = { value: timezone, expires: 1.year }
      Current.timezone = timezone
      head :ok
    else
      head :unprocessable_entity
    end
  end
end
