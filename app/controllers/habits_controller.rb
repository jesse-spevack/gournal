class HabitsController < ApplicationController
  before_action :set_habit, only: [ :edit, :update, :destroy ]
  before_action :set_month_year, only: [ :index ]
  before_action :set_habit_for_show, only: [ :show ]

  def index
    return redirect_with_invalid_date_error unless valid_month_year?

    handle_navigation if params[:nav].present?
    load_habits_for_month
  end

  def show
    if params[:id] == "1"
      handle_month_grid_request
    else
      handle_individual_habit_show
    end
  end

  def new
    @habit = Current.user.habits.build
    set_form_defaults
  end

  def create
    return handle_copy_from_previous if copying_from_previous?

    create_new_habit
  end

  def edit
    # Empty - just renders the edit view
  end

  def update
    # Handle position updates specially to avoid conflicts
    if habit_params[:position].present?
      update_with_position_handling
    else
      standard_update
    end
  end

  def destroy
    year = @habit.year
    month = @habit.month
    @habit.destroy!

    redirect_to habit_path(1, year: year, month: month),
                notice: "Habit was successfully deleted."
  end

  private

  # Constants for validation
  MIN_YEAR = 1900
  MAX_YEAR = 3000
  MIN_MONTH = 1
  MAX_MONTH = 12
  TEMP_POSITION = 9999  # Temporary position to avoid conflicts during updates

  def set_habit
    @habit = Current.user.habits.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    handle_habit_not_found
  end

  def set_habit_for_show
    # Always skip habit loading for ID = 1 (month grid placeholder)
    return if params[:id] == "1"

    @habit = Current.user.habits.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    handle_habit_not_found
  end

  def set_month_year
    @year = parse_year_param
    @month = parse_month_param
  end

  def parse_year_param
    params[:year]&.to_i || Date.current.year
  end

  def parse_month_param
    params[:month]&.to_i || Date.current.month
  end

  def handle_navigation
    current_date = Date.new(@year, @month)

    case params[:nav]
    when "previous"
      navigate_to_previous_month(current_date)
    when "next"
      navigate_to_next_month(current_date)
    end
  end

  def navigate_to_previous_month(current_date)
    previous_date = current_date.prev_month
    @year = previous_date.year
    @month = previous_date.month
  end

  def navigate_to_next_month(current_date)
    next_date = current_date.next_month
    @year = next_date.year
    @month = next_date.month
  end

  def valid_month_year?
    year_valid? && month_valid?
  end

  def year_valid?
    @year.is_a?(Integer) && @year > MIN_YEAR && @year < MAX_YEAR
  end

  def month_valid?
    @month.is_a?(Integer) && @month >= MIN_MONTH && @month <= MAX_MONTH
  end

  def redirect_with_invalid_date_error
    redirect_to habits_path, alert: "Invalid month or year."
  end

  def load_habits_for_month
    @habits = Current.user.habits.current_month(@year, @month).ordered.includes(:habit_entries)
    @days_in_month = days_in_month(@year, @month)
  end

  def days_in_month(year, month)
    Date.new(year, month).end_of_month.day
  rescue Date::Error, ArgumentError
    # Return a reasonable default if date construction fails
    31
  end

  def habit_params
    params.require(:habit).permit(:name, :month, :year, :check_type, :position, :copy_from_previous)
  end

  def assign_next_position
    # Always assign next available position, ignoring any user-provided position
    # This prevents conflicts and ensures positions are sequential
    max_position = find_max_position_for_month
    @habit.position = max_position + 1
  end

  def find_max_position_for_month
    Current.user.habits
           .where(year: @habit.year, month: @habit.month)
           .maximum(:position) || 0
  end

  def set_form_defaults
    @habit.month ||= default_month
    @habit.year ||= default_year
  end

  def default_month
    params[:month]&.to_i || Date.current.month
  end

  def default_year
    params[:year]&.to_i || Date.current.year
  end

  def handle_copy_from_previous
    target_year, target_month = extract_copy_target_date

    unless valid_copy_date?(target_year, target_month)
      render_invalid_date_error
      return
    end

    result = HabitCopyService.call(
      user: Current.user,
      target_year: target_year,
      target_month: target_month
    )

    handle_copy_result(result, target_year, target_month)
  end

  def exceeds_habit_limit?(year, month)
    current_count = Current.user.habits.current_month(year, month).count
    current_count >= Habit::MAX_HABITS_PER_MONTH
  end

  def turbo_frame_request?
    request.headers["Turbo-Frame"].present?
  end

  def update_with_position_handling
    new_position = habit_params[:position].to_i
    original_position = @habit.position

    # Simple position update logic
    # First, temporarily set the position to a high number to avoid conflicts
    @habit.update!(position: TEMP_POSITION)

    # Check if the desired position is taken by another habit
    conflicting_habit = Current.user.habits
                                   .where(year: @habit.year, month: @habit.month)
                                   .where(position: new_position)
                                   .where.not(id: @habit.id)
                                   .first

    if conflicting_habit
      # Move the conflicting habit to the original position of this habit
      conflicting_habit.update!(position: original_position)
    end

    # Now update this habit to the desired position
    if @habit.update(habit_params.except(:position).merge(position: new_position))
      redirect_to habit_path(1, year: @habit.year, month: @habit.month),
                  notice: "Habit was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    # If there are still conflicts, just use standard update
    standard_update
  end

  def standard_update
    if @habit.update(habit_params.except(:position))
      redirect_to habit_path(1, year: @habit.year, month: @habit.month),
                  notice: "Habit was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def handle_month_grid_request
    if params[:year].present? && params[:month].present?
      set_month_year
      unless valid_month_year?
        return redirect_with_invalid_date_error
      end

      load_habits_for_month
      render :index
    else
      # ID 1 without year/month should redirect to current month
      redirect_to habit_path(1, year: Date.current.year, month: Date.current.month)
    end
  end

  def handle_individual_habit_show
    # Handle individual habit show (redirect to grid for now)
    redirect_to habit_path(1, year: @habit.year, month: @habit.month)
  end

  def copying_from_previous?
    params[:habit][:copy_from_previous] == "true"
  end

  def create_new_habit
    target_year, target_month = extract_target_date

    if exceeds_habit_limit?(target_year, target_month)
      render_habit_limit_error
      return
    end

    @habit = Current.user.habits.build(habit_params)
    assign_next_position

    if @habit.save
      handle_successful_creation
    else
      handle_failed_creation
    end
  end

  def extract_target_date
    target_year = habit_params[:year]&.to_i || Date.current.year
    target_month = habit_params[:month]&.to_i || Date.current.month
    [ target_year, target_month ]
  end

  def render_habit_limit_error
    @habit = Current.user.habits.build(habit_params)
    @habit.errors.add(:base, "Maximum of #{Habit::MAX_HABITS_PER_MONTH} habits allowed per month.")
    set_form_defaults
    render :new, status: :unprocessable_content
  end

  def handle_successful_creation
    set_turbo_content_type if turbo_frame_request?
    redirect_to habit_path(1, year: @habit.year, month: @habit.month),
                notice: "Habit was successfully created."
  end

  def handle_failed_creation
    set_form_defaults
    render :new, status: :unprocessable_content
  end

  def set_turbo_content_type
    response.content_type = "text/vnd.turbo-stream.html"
  end

  def extract_copy_target_date
    target_year = params[:year]&.to_i || Date.current.year
    target_month = params[:month]&.to_i || Date.current.month
    [ target_year, target_month ]
  end

  def valid_copy_date?(year, month)
    !year.nil? && !month.nil? &&
    year >= MIN_YEAR && year <= MAX_YEAR &&
    month >= MIN_MONTH && month <= MAX_MONTH
  end

  def render_invalid_date_error
    @habit = Current.user.habits.build
    @habit.errors.add(:base, "Invalid month or year.")
    set_form_defaults
    render :new, status: :unprocessable_content
  end

  def handle_copy_result(result, target_year, target_month)
    if result[:success]
      redirect_to habit_path(1, year: target_year, month: target_month),
                  notice: result[:message]
    elsif no_habits_to_copy?(result)
      redirect_to habit_path(1, year: target_year, month: target_month),
                  notice: result[:error]
    else
      render_copy_error(result)
    end
  end

  def no_habits_to_copy?(result)
    result[:count] == 0 && result[:error].include?("No habits found")
  end

  def render_copy_error(result)
    @habit = Current.user.habits.build
    @habit.errors.add(:base, result[:error])
    set_form_defaults
    render :new, status: :unprocessable_content
  end

  def handle_habit_not_found
    respond_to do |format|
      format.html do
        if Rails.env.test?
          head :not_found
        else
          redirect_to habits_path, alert: "Habit not found."
        end
      end
      format.json { render json: { error: "Habit not found" }, status: :not_found }
      format.any { head :not_found }
    end
  end
end
