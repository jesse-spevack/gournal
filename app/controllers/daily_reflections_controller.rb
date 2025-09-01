class DailyReflectionsController < ApplicationController
  allow_unauthenticated_access

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def create
    user_email = ENV["FIRST_USER"]
    @current_user = User.find_by(email_address: user_email)
    @current_user ||= User.first

    unless @current_user
      return render json: {
        status: "error",
        message: "No user found"
      }, status: :unauthorized
    end

    @daily_reflection = @current_user.daily_reflections.build(daily_reflection_params)

    if @daily_reflection.save
      render json: {
        status: "success",
        id: @daily_reflection.id,
        content: @daily_reflection.content
      }
    else
      render json: {
        status: "error",
        errors: @daily_reflection.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    @daily_reflection = DailyReflection.find(params[:id])

    if @daily_reflection.update(daily_reflection_params)
      render json: {
        status: "success",
        id: @daily_reflection.id,
        content: @daily_reflection.content
      }
    else
      render json: {
        status: "error",
        errors: @daily_reflection.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def daily_reflection_params
    params.require(:daily_reflection).permit(:content, :date)
  end

  def record_not_found
    render json: {
      status: "error",
      message: "Reflection not found"
    }, status: :not_found
  end
end
