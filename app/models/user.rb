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

  validates :slug, uniqueness: { case_sensitive: false },
                   format: { with: /\A[a-z0-9_-]+\z/,
                            message: "can only contain lowercase letters, numbers, underscores, and dashes" },
                   length: { minimum: 3, maximum: 30 },
                   allow_blank: true

  # Normalizations
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :slug, with: ->(s) { s.strip.downcase if s.present? }

  # Scopes
  scope :with_slug, -> { where.not(slug: [ nil, "" ]) }

  # Public profile methods
  def has_public_profile?
    slug.present?
  end

  def public_habits_visible?
    habits_public? && has_public_profile?
  end

  def public_reflections_visible?
    reflections_public? && has_public_profile?
  end
end
