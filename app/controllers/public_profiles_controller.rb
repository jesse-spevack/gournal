class PublicProfilesController < ApplicationController
  allow_unauthenticated_access

  def show
    @user = User.find_by!(slug: params[:slug])

    # Extract year and month from params or use current
    current_date = Date.current
    year = params[:year]&.to_i || current_date.year
    month = params[:month]&.to_i || current_date.month

    # Validate year and month parameters
    unless valid_date_params?(year, month)
      year = current_date.year
      month = current_date.month
    end

    # Build tracker data with privacy checks
    @tracker_data = PublicProfileDataBuilder.call(
      user: @user,
      year: year,
      month: month
    )

    # Set current date for navigation
    @current_date = Date.new(year, month, 1)
    @current_year_month = @current_date.strftime("%Y-%m")

    # Use the public profile view (not the habit_entries view)

  rescue ActiveRecord::RecordNotFound
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
  end

  private

  def valid_date_params?(year, month)
    return false unless year.is_a?(Integer) && month.is_a?(Integer)
    return false unless year >= 2000 && year <= 2100
    return false unless month >= 1 && month <= 12

    true
  end
end
