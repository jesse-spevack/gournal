class Habit < ApplicationRecord
  belongs_to :user
  has_many :habit_entries
  
  # Constants for validation
  MIN_MONTH = 1
  MAX_MONTH = 12
  
  # Validations
  validates :name, presence: true
  validates :month, presence: true, numericality: { greater_than_or_equal_to: MIN_MONTH, less_than_or_equal_to: MAX_MONTH }
  validates :year, presence: true
  validates :position, presence: true, uniqueness: { scope: [:user_id, :year, :month] }
  
  # Scopes
  scope :current_month, ->(year, month) { where(year: year, month: month) }
  scope :ordered, -> { order(:position) }
  
  def self.copy_from_previous_month(user, target_year, target_month)
    previous_year, previous_month = calculate_previous_month(target_year, target_month)
    previous_habits = where(user: user, year: previous_year, month: previous_month)
    
    copy_habits_to_month(previous_habits, target_year, target_month)
  end

  private

  # Calculate the previous month and year given a target month/year
  def self.calculate_previous_month(target_year, target_month)
    if target_month == 1
      [target_year - 1, 12]
    else
      [target_year, target_month - 1]
    end
  end

  # Copy a collection of habits to a new month/year
  def self.copy_habits_to_month(habits, target_year, target_month)
    habits.map do |habit|
      copied_habit = habit.dup
      copied_habit.assign_attributes(year: target_year, month: target_month)
      copied_habit.save!
      copied_habit
    end
  end
end