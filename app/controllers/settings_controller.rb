class SettingsController < ApplicationController
  def index
    @user = Current.user
  end
end
