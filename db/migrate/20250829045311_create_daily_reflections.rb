class CreateDailyReflections < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_reflections do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.text :content

      t.timestamps
    end
    
    add_index :daily_reflections, [:user_id, :date], unique: true
  end
end
