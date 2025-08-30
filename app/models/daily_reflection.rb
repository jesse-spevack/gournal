class DailyReflection < ApplicationRecord
  belongs_to :user

  # Validations
  validates :date, presence: true
  validates :date, uniqueness: { scope: :user_id }

  # Scopes
  scope :for_date, ->(date) { where(date: date) }
  scope :recent, -> { order(date: :desc) }
  scope :for_month, ->(year, month) {
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month
    where(date: start_date..end_date)
  }
end
