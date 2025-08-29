class DailyReflection < ApplicationRecord
  belongs_to :user
  
  # Constants
  MAX_CONTENT_LENGTH = 255
  
  # Validations
  validates :date, presence: true
  validates :date, uniqueness: { scope: :user_id }
  validates :content, length: { maximum: MAX_CONTENT_LENGTH }
  
  # Scopes
  scope :for_date, ->(date) { where(date: date) }
  scope :recent, -> { order(date: :desc) }
  scope :for_month, ->(year, month) { 
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month
    where(date: start_date..end_date)
  }
  
  # Check if reflection has content
  def has_content?
    content.present?
  end
end