class TimezoneController < ApplicationController
  allow_unauthenticated_access

  def create
    timezone = params[:timezone]

    if ActiveSupport::TimeZone::MAPPING.value?(timezone)
      cookies[:tz] = {
        value: timezone,
        expires: 1.year.from_now,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax
      }
      Current.timezone = timezone
      head :ok
    else
      head :unprocessable_entity
    end
  end
end
