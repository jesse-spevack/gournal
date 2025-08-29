class CreateHabitEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :habit_entries do |t|
      t.references :habit, null: false, foreign_key: true
      t.integer :day, null: false
      t.boolean :completed, default: false, null: false
      t.integer :checkbox_style
      t.integer :check_style

      t.timestamps
    end
    
    add_index :habit_entries, [:habit_id, :day], unique: true
  end
end
