class HelpController < ApplicationController
  before_action :require_authentication

  def manage_habits
    # Help page for habit management
  end

  def next_month_setup
    # Help page for month setup process
  end

  def profile_sharing
    # Help page for profile sharing
  end

  def profile_link
    # Help page for profile link
  end

  def sharing_settings
    # Help page for sharing settings
  end
end
