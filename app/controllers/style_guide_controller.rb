class StyleGuideController < ApplicationController
  def index
    if Rails.env.production?
      redirect_to root_path
      return
    end
  end
end