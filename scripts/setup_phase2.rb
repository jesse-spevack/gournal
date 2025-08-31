#!/usr/bin/env ruby
# Phase 2 Setup Script - Creates user and September 2025 habits

puts "Setting up Phase 2 data for September 2025..."

# Create user with specific email and password
user = User.find_or_create_by!(email_address: "jspevack@gmail.com") do |u|
  u.password = "gournal"
  puts "Created user: #{u.email_address}"
end

# Define the 5 habits for September 2025 (in order, left to right)
habits_data = [
  { name: "Run 1 mile", position: 1 },
  { name: "20 pushups", position: 2 },
  { name: "Stretch", position: 3 },
  { name: "Track all food", position: 4 },
  { name: "Bed by 10", position: 5 }
]

september_2025_year = 2025
september_2025_month = 9
days_in_september = 30

puts "Creating habits for September 2025..."

habits_data.each do |habit_data|
  habit = Habit.find_or_create_by!(
    user: user,
    name: habit_data[:name],
    month: september_2025_month,
    year: september_2025_year,
    position: habit_data[:position]
  ) do |h|
    h.check_type = :x_marks  # All habits use X marks (not blots)
    puts "  Created habit: #{h.name} (position #{h.position})"
  end

  # Create habit entries for all 30 days of September
  (1..days_in_september).each do |day|
    entry = HabitEntry.find_or_create_by!(
      habit: habit,
      day: day
    ) do |e|
      # The model's before_create callback will assign random styles
      puts "    Created entry for day #{day}"
    end
  end
end

puts "\nSetup complete!"
puts "- User: #{user.email_address} (password: gournal)"
puts "- #{Habit.where(user: user, year: september_2025_year, month: september_2025_month).count} habits for September 2025"
puts "- #{HabitEntry.joins(:habit).where(habits: { user: user, year: september_2025_year, month: september_2025_month }).count} habit entries"
puts "- All habits use X marks check type"
puts "- Random box styles and X styles assigned to each entry"
