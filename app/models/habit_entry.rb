class HabitEntry < ApplicationRecord
  belongs_to :habit, touch: true

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

  # Style pattern constants for better maintainability
  X_STYLE_PREFIX = "x_style_".freeze
  BLOT_STYLE_PREFIX = "blot_style_".freeze

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
    self.checkbox_style ||= HabitEntryStyleSelector.random_checkbox_style
    self.check_style ||= HabitEntryStyleSelector.random_check_style_for(habit.check_type)
  end
end
