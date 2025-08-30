class CreateHabits < ActiveRecord::Migration[8.0]
  def change
    create_table :habits do |t|
      t.string :name, null: false
      t.integer :month, null: false
      t.integer :year, null: false
      t.integer :position, null: false
      t.boolean :active, null: false, default: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :habits, [ :user_id, :year, :month, :position ], unique: true
  end
end
