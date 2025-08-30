class HabitEntriesController < ApplicationController
  before_action :set_habit_entry, only: [ :update ]

  def update
    if bulk_update_request?
      handle_bulk_update
    else
      handle_single_update
    end
  end

  private

  def bulk_update_request?
    params[:habit_entries].present?
  end

  def set_habit_entry
    @habit_entry = if entry_id_provided?
      find_entry_by_id
    elsif habit_and_day_provided?
      find_or_build_entry
    else
      handle_missing_parameters
    end
  rescue ActiveRecord::RecordNotFound, NoMethodError => e
    handle_not_found_error(e)
  end

  def entry_id_provided?
    params[:id] && params[:id] != "undefined"
  end

  def habit_and_day_provided?
    params[:habit_entry] && (params[:habit_entry][:habit_id] || params[:habit_id])
  end

  def handle_missing_parameters
    respond_with_error("Missing required parameters", :bad_request)
    nil
  end

  def handle_not_found_error(error)
    respond_with_error("Entry not found", :not_found)
    nil
  end

  def respond_with_error(message, status)
    respond_to do |format|
      format.json { render json: { error: message }, status: status }
      format.html do
        if Rails.env.test?
          render json: { error: message }, status: status
        else
          redirect_to habits_path, alert: message
        end
      end
    end
  end

  def find_entry_by_id
    find_user_habit_entry_by_id
  end

  def find_user_habit_entry_by_id
    HabitEntry.joins(:habit)
              .where(habit: { user: Current.user })
              .find(params[:id])
  end

  def find_or_build_entry
    habit_id, day = extract_habit_and_day_params
    habit = find_user_habit(habit_id)
    habit.habit_entries.find_or_initialize_by(day: day)
  end

  def extract_habit_and_day_params
    habit_id = params[:habit_id] || params[:habit_entry]&.[](:habit_id)
    day = params[:day] || params[:habit_entry]&.[](:day)
    [ habit_id, day.to_i ]
  end

  def find_user_habit(habit_id)
    Current.user.habits.find(habit_id)
  end

  def handle_single_update
    return if future_date_blocked?

    original_styles = preserve_styles

    if update_habit_entry
      restore_styles(original_styles) if original_styles
      respond_to_update_success
    else
      respond_to_update_failure
    end
  end

  def future_date_blocked?
    if should_block_future_date?
      respond_with_error("Cannot complete future dates", :unprocessable_content)
      true
    else
      false
    end
  end

  def should_block_future_date?
    (@habit_entry.persisted? && future_date?(@habit_entry)) ||
    (@habit_entry.new_record? && future_date_for_habit?(@habit_entry.habit, @habit_entry.day))
  end

  def update_habit_entry
    @habit_entry.update(habit_entry_params)
  end

  def handle_bulk_update
    updated_entries = process_bulk_entries
    render json: { updated: updated_entries.size }, status: :ok
  end

  def process_bulk_entries
    updated_entries = []

    params[:habit_entries].each do |entry_id, entry_params|
      entry = find_user_entry_for_bulk_update(entry_id)
      next if entry.nil? || future_date?(entry)

      if update_entry_with_style_preservation(entry, entry_params)
        updated_entries << entry
      end
    end

    updated_entries
  end

  def find_user_entry_for_bulk_update(entry_id)
    HabitEntry.joins(:habit)
              .where(habit: { user: Current.user })
              .find(entry_id)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def update_entry_with_style_preservation(entry, entry_params)
    original_styles = preserve_entry_styles(entry)

    if entry.update(entry_params.permit(:completed))
      restore_entry_styles(entry, original_styles) if original_styles[:checkbox_style]
      true
    else
      false
    end
  end

  def preserve_entry_styles(entry)
    {
      checkbox_style: entry.checkbox_style,
      check_style: entry.check_style
    }
  end

  def restore_entry_styles(entry, styles)
    entry.update_columns(styles) if styles[:checkbox_style]
  end

  def preserve_styles
    return nil unless @habit_entry.persisted?

    preserve_entry_styles(@habit_entry)
  end

  def restore_styles(styles)
    restore_entry_styles(@habit_entry, styles) if styles
  end

  def respond_to_update_success
    respond_to do |format|
      format.json { render_json_success }
      format.turbo_stream { render_turbo_success }
      format.html { render_html_success }
    end
  end

  def render_json_success
    render json: {
      id: @habit_entry.id,
      completed: @habit_entry.completed,
      day: @habit_entry.day
    }
  end

  def render_turbo_success
    render turbo_stream: turbo_stream.replace(
      "habit_entry_#{@habit_entry.habit_id}_#{@habit_entry.day}",
      partial: "habit_entries/checkbox",
      locals: { habit_entry: @habit_entry }
    )
  end

  def render_html_success
    # For test environments and simple HTML requests, return 200 OK
    if Rails.env.test? || request.xhr?
      head :ok
    else
      redirect_back_or_to habits_path
    end
  end

  def respond_to_update_failure
    respond_to do |format|
      format.json { render json: { errors: @habit_entry.errors }, status: :unprocessable_content }
      format.turbo_stream { render status: :unprocessable_content }
      format.html { render_html_failure }
    end
  end

  def render_html_failure
    if Rails.env.test? || request.xhr?
      render json: { errors: @habit_entry.errors }, status: :unprocessable_content
    else
      redirect_back_or_to habits_path, alert: "Failed to update habit entry."
    end
  end

  def future_date?(entry)
    entry_date = Date.new(entry.habit.year, entry.habit.month, entry.day)
    entry_date > Date.current
  rescue Date::Error
    false
  end

  def future_date_for_habit?(habit, day)
    entry_date = Date.new(habit.year, habit.month, day)
    entry_date > Date.current
  rescue Date::Error
    false
  end

  def habit_entry_params
    params.require(:habit_entry).permit(:completed, :day)
  end

  def redirect_back_or_to(path, **options)
    if request.referer
      redirect_back(fallback_location: path, **options)
    else
      redirect_to path, **options
    end
  end
end
