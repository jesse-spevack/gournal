class HabitDataTimestamp
  def self.call(user:, year:, month:)
    new(user: user, year: year, month: month).call
  end

  def initialize(user:, year:, month:)
    @user = user
    @year = year
    @month = month
  end

  def call
    habits_timestamp = @user.habits
      .where(year: @year, month: @month, active: true)
      .maximum(:updated_at)

    habit_ids = @user.habits
      .where(year: @year, month: @month, active: true)
      .pluck(:id)

    entries_timestamp = if habit_ids.any?
      HabitEntry.where(habit_id: habit_ids).maximum(:updated_at)
    end

    most_recent = [ habits_timestamp, entries_timestamp ].compact.max

    most_recent || Time.zone.local(@year, @month, 1).beginning_of_month
  end

  private

  attr_reader :user, :year, :month
end
