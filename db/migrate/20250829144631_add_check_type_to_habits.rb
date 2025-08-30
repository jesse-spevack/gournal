class AddCheckTypeToHabits < ActiveRecord::Migration[8.0]
  def change
    add_column :habits, :check_type, :integer
  end
end
