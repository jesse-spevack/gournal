class Habit < ApplicationRecord
  belongs_to :user
  has_many :habit_entries, dependent: :destroy

  # The 'active' field (boolean, default: true) allows habits to be soft-deleted
  # or temporarily disabled while preserving historical data. This is useful when
  # users want to pause a habit without losing their progress history.

  # Enums
  enum :check_type, {
    x_marks: 0,
    blots: 1
  }

  # Check type constants for better maintainability and consistency
  CHECK_TYPE_X_MARKS = "x_marks".freeze
  CHECK_TYPE_BLOTS = "blots".freeze

  # Constants for validation
  MIN_MONTH = 1
  MAX_MONTH = 12

  # Validations
  validates :name, presence: true
  validates :month, presence: true, numericality: { greater_than_or_equal_to: MIN_MONTH, less_than_or_equal_to: MAX_MONTH }
  validates :year, presence: true
  validates :position, presence: true, uniqueness: { scope: [ :user_id, :year, :month ] }

  # Validations for check_type
  validates :check_type, presence: true

  # Scopes
  scope :current_month, ->(year, month) { where(year: year, month: month) }
  scope :ordered, -> { order(:position) }

  # Copy all habits from the previous month to the target month
  # Delegates to HabitCopyService for better separation of concerns
  def self.copy_from_previous_month(user, target_year, target_month)
    HabitCopyService.new(user: user, target_year: target_year, target_month: target_month).call
  end
end
