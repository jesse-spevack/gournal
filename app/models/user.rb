class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :sessions, dependent: :destroy
  has_many :habits, dependent: :destroy
  has_many :habit_entries, through: :habits
  has_many :daily_reflections, dependent: :destroy

  # Enums
  enum :onboarding_state, {
    not_started: 0,
    habits_created: 1,
    profile_created: 2,
    completed: 3,
    skipped: 4
  }, default: :not_started

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

  # Onboarding helper methods
  def in_onboarding?
    not_started? || habits_created? || profile_created?
  end

  def onboarding_finished?
    completed? || skipped?
  end

  def advance_onboarding_to(new_state)
    return if onboarding_finished?

    # Only allow forward progression
    current_index = self.class.onboarding_states[onboarding_state]
    new_index = self.class.onboarding_states[new_state]

    if new_index > current_index
      update(onboarding_state: new_state)
    end
  end
end
