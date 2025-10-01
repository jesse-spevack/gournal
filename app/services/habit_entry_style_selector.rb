class HabitEntryStyleSelector
  def self.random_checkbox_style
    HabitEntry.checkbox_styles.keys.sample
  end

  def self.random_check_style_for(check_type)
    case check_type
    when Habit::CHECK_TYPE_X_MARKS
      x_style_options.sample
    when Habit::CHECK_TYPE_BLOTS
      blot_style_options.sample
    else
      HabitEntry.check_styles.keys.sample
    end
  end

  def self.x_style_options
    @x_style_options ||= HabitEntry.check_styles.keys.select { |k| k.start_with?(HabitEntry::X_STYLE_PREFIX) }
  end

  def self.blot_style_options
    @blot_style_options ||= HabitEntry.check_styles.keys.select { |k| k.start_with?(HabitEntry::BLOT_STYLE_PREFIX) }
  end
end
