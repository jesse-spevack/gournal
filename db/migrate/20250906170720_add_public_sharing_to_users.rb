class AddPublicSharingToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :slug, :string
    add_index :users, :slug, unique: true
    add_column :users, :habits_public, :boolean, default: false, null: false
    add_column :users, :reflections_public, :boolean, default: false, null: false
  end
end
