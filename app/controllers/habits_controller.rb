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
    # Check if this is a month grid request (ID = 1 is the placeholder for month grid)
    if params[:id] == "1"
      # For month grid, we need year and month parameters
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
    else
      # Handle individual habit show (redirect to grid for now)
      redirect_to habit_path(1, year: @habit.year, month: @habit.month)
    end
  end

  def new
    @habit = Current.user.habits.build
    set_form_defaults
  end

  def create
    @habit = Current.user.habits.build(habit_params)
    assign_next_position

    if @habit.save
      redirect_to habit_path(1, year: @habit.year, month: @habit.month),
                  notice: "Habit was successfully created."
    else
      set_form_defaults
      render :new, status: :unprocessable_content
    end
  end

  def edit
    # Empty - just renders the edit view
  end

  def update
    if @habit.update(habit_params)
      redirect_to habit_path(1, year: @habit.year, month: @habit.month),
                  notice: "Habit was successfully updated."
    else
      render :edit, status: :unprocessable_content
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
    params.require(:habit).permit(:name, :month, :year, :check_type, :position)
  end

  def assign_next_position
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
