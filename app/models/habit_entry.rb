class HabitEntry < ApplicationRecord
  include CheckboxRenderable

  belongs_to :habit

  # Enums
  enum :checkbox_style, {
    box_style_0: 0,
    box_style_1: 1,
    box_style_2: 2,
    box_style_3: 3,
    box_style_4: 4,
    box_style_5: 5,
    box_style_6: 6,
    box_style_7: 7,
    box_style_8: 8,
    box_style_9: 9
  }

  enum :check_style, {
    x_style_0: 0,
    x_style_1: 1,
    x_style_2: 2,
    x_style_3: 3,
    x_style_4: 4,
    x_style_5: 5,
    x_style_6: 6,
    x_style_7: 7,
    x_style_8: 8,
    x_style_9: 9,
    blot_style_0: 10,
    blot_style_1: 11,
    blot_style_2: 12,
    blot_style_3: 13,
    blot_style_4: 14,
    blot_style_5: 15,
    blot_style_6: 16,
    blot_style_7: 17,
    blot_style_8: 18,
    blot_style_9: 19
  }

  # Constants for validation
  MIN_DAY = 1
  MAX_DAY = 31

  # Validations
  validates :day, presence: true, numericality: { greater_than_or_equal_to: MIN_DAY, less_than_or_equal_to: MAX_DAY }
  validates :day, uniqueness: { scope: :habit_id }

  # Callbacks
  before_create :assign_random_styles

  # Get the actual date this entry represents
  def entry_date
    Date.new(habit.year, habit.month, day)
  end

  private

  # Assign random styles before creation if not already set
  def assign_random_styles
    self.checkbox_style ||= random_checkbox_style
    self.check_style ||= random_check_style
  end

  def random_checkbox_style
    self.class.checkbox_styles.keys.sample
  end

  # Select random check style based on the habit's check type
  # Ensures visual consistency: x_marks habits use x_styles, blots habits use blot_styles
  def random_check_style
    case habit.check_type
    when Habit::CHECK_TYPE_X_MARKS
      x_style_options.sample
    when Habit::CHECK_TYPE_BLOTS
      blot_style_options.sample
    end
  end

  # Style filtering methods - each returns appropriate styles based on habit type
  def x_style_options
    @x_style_options ||= filter_styles_by_prefix(X_STYLE_PREFIX)
  end

  def blot_style_options
    @blot_style_options ||= filter_styles_by_prefix(BLOT_STYLE_PREFIX)
  end

  def filter_styles_by_prefix(prefix)
    self.class.check_styles.keys.select { |key| key.start_with?(prefix) }
  end
end
