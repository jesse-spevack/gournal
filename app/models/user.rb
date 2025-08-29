class User < ApplicationRecord
  has_secure_password
  
  # Associations
  has_many :sessions, dependent: :destroy
  has_many :habits, dependent: :destroy
  has_many :habit_entries, through: :habits
  has_many :daily_reflections, dependent: :destroy

  # Normalizations
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  
  # Get habits for a specific month, ordered by position
  def habits_for_month(year, month)
    habits.current_month(year, month).ordered
  end
  
  # Get daily reflections for a specific month
  def reflections_for_month(year, month)
    daily_reflections.for_month(year, month)
  end
  
  # Get reflection for a specific date (or nil if none exists)
  def reflection_for_date(date)
    daily_reflections.for_date(date).first
  end
end
