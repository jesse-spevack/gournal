class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :sessions, dependent: :destroy
  has_many :habits, dependent: :destroy
  has_many :habit_entries, through: :habits
  has_many :daily_reflections, dependent: :destroy

  # Validations
  validates :email_address, presence: true,
                           uniqueness: { case_sensitive: false },
                           format: { with: URI::MailTo::EMAIL_REGEXP,
                                   message: "must be a valid email address" }

  # Normalizations
  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
