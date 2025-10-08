class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_timezone

  private

  def set_timezone
    tz = cookies[:tz]
    Current.timezone = tz if tz.present? && ActiveSupport::TimeZone::MAPPING.value?(tz)
  end
end
