# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Simple seed data for development
if Rails.env.development?
  puts "Creating seed data..."

  # Find or create demo user
  user = User.find_or_create_by!(email_address: "demo@example.com") do |u|
    u.password = "password"
  end

  puts "Demo user: #{user.email_address}"

  # Generate 3 months of habit data
  3.times do |month_offset|
    date = month_offset.months.ago

    # Create habits with different completion patterns
    habits_data = [
      { name: "Exercise", completion_rate: 0.8 },
      { name: "Reading", completion_rate: 0.6 },
      { name: "Meditation", completion_rate: 0.9 },
      { name: "Journaling", completion_rate: 0.7 },
      { name: "Water intake", completion_rate: 0.85 }
    ]

    habits_data.each_with_index do |habit_data, position|
      # Find or create habit for this month
      habit = Habit.find_or_create_by!(
        user: user,
        name: habit_data[:name],
        month: date.month,
        year: date.year
      ) do |h|
        h.position = position + 1
        # check_type will be randomly assigned by callback
      end

      # Generate entries with realistic patterns
      days_in_month = Date.new(date.year, date.month, -1).day
      days_in_month.times do |day|
        # Find or create entry for this day
        entry = HabitEntry.find_or_create_by!(
          habit: habit,
          day: day + 1
        )
        # checkbox_style and check_style are assigned by callbacks based on habit's check_type

        # Complete based on completion rate with some randomness
        # Only mark as completed if the day is in the past
        entry_date = Date.new(date.year, date.month, day + 1)
        if entry_date <= Date.current && rand < habit_data[:completion_rate]
          entry.update!(completed: true)
        end
      end
    end

    # Add some daily reflections for the month
    5.times do
      random_day = rand(1..Date.new(date.year, date.month, -1).day)
      reflection_date = Date.new(date.year, date.month, random_day)

      # Only create reflections for past dates
      if reflection_date <= Date.current
        DailyReflection.find_or_create_by!(
          user: user,
          date: reflection_date
        ) do |r|
          reflections = [
            "Great day! Feeling productive.",
            "Challenging but made progress.",
            "Need to focus more tomorrow.",
            "Proud of today's accomplishments.",
            "Learning and growing each day."
          ]
          r.content = reflections.sample
        end
      end
    end
  end

  puts "Seed data created:"
  puts "- User: demo@example.com (password: password)"
  puts "- #{Habit.count} habits across 3 months"
  puts "- #{HabitEntry.count} habit entries"
  puts "- #{DailyReflection.count} daily reflections"
  puts "- Check types distribution: #{Habit.group(:check_type).count}"

  # Show a sample of the check styles being used
  sample_habits = Habit.limit(5)
  puts "\nSample habit check types:"
  sample_habits.each do |habit|
    puts "  #{habit.name} (#{habit.month}/#{habit.year}): #{habit.check_type}"
  end
end
