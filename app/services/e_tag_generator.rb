require "digest"

class ETagGenerator
  def self.call(user:, year: Date.current.year, month: Date.current.month, last_modified: nil)
    new(user: user, year: year, month: month, last_modified: last_modified).call
  end

  def initialize(user:, year:, month:, last_modified: nil)
    raise ArgumentError, "User cannot be nil" if user.nil?

    @user = user
    @year = year
    @month = month
    @last_modified = last_modified
  end

  def call
    # Build ETag from components that affect the habit tracking page
    etag_components = [
      @user.id,
      @year,
      @month,
      habits_fingerprint,
      habit_entries_fingerprint,
      last_modified_fingerprint
    ]

    # Generate MD5 hash of the combined components
    Digest::MD5.hexdigest(etag_components.join("-"))
  end

  private

  def habits_fingerprint
    # Use pluck to get only the data we need for fingerprinting
    habit_data = @user.habits
      .where(year: @year, month: @month, active: true)
      .order(:id)
      .pluck(:id, :name, :position, :check_type, :updated_at)

    return "no-habits" if habit_data.empty?

    # Convert to strings and create fingerprint
    fingerprint_data = habit_data.map do |id, name, position, check_type, updated_at|
      "#{id}:#{name}:#{position}:#{check_type}:#{updated_at.to_i}"
    end

    Digest::MD5.hexdigest(fingerprint_data.join("|"))
  end

  def habit_entries_fingerprint
    # Get habit IDs first
    habit_ids = @user.habits
      .where(year: @year, month: @month, active: true)
      .pluck(:id)

    return "no-entries" if habit_ids.empty?

    # Use pluck to get only the entry data we need
    entry_data = HabitEntry
      .where(habit_id: habit_ids)
      .order(:id)
      .pluck(:id, :habit_id, :day, :completed, :updated_at)

    return "no-entries" if entry_data.empty?

    # Convert to strings and create fingerprint
    fingerprint_data = entry_data.map do |id, habit_id, day, completed, updated_at|
      "#{id}:#{habit_id}:#{day}:#{completed ? '1' : '0'}:#{updated_at.to_i}"
    end

    Digest::MD5.hexdigest(fingerprint_data.join("|"))
  end

  def last_modified_fingerprint
    # Include last_modified timestamp in ETag calculation if provided
    return "no-timestamp" unless @last_modified

    @last_modified.to_i.to_s
  end
end
