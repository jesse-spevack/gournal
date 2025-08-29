class HabitEntry < ApplicationRecord
  belongs_to :habit
  
  # Enums
  enum :checkbox_style, {
    box_style_1: 0,
    box_style_2: 1,
    box_style_3: 2,
    box_style_4: 3,
    box_style_5: 4
  }
  
  enum :check_style, {
    x_style_1: 0,
    x_style_2: 1,
    x_style_3: 2,
    x_style_4: 3,
    x_style_5: 4
  }
  
  # Constants for validation
  MIN_DAY = 1
  MAX_DAY = 31

  # Validations
  validates :day, presence: true, numericality: { greater_than_or_equal_to: MIN_DAY, less_than_or_equal_to: MAX_DAY }
  validates :day, uniqueness: { scope: :habit_id }
  validate :no_future_date_completion
  
  # Callbacks
  before_create :assign_random_styles
  
  # Get the actual date this entry represents
  def entry_date
    Date.new(habit.year, habit.month, day)
  end
  
  private
  
  def assign_random_styles
    self.checkbox_style ||= self.class.checkbox_styles.keys.sample
    self.check_style ||= self.class.check_styles.keys.sample
  end
  
  def no_future_date_completion
    return unless completed? && habit.present?
    
    if entry_date > Date.current
      errors.add(:completed, "cannot be completed for future dates")
    end
  end
end