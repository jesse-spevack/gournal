class AddOnboardingStateToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :onboarding_state, :integer, default: 0, null: false

    # Set existing users to completed so they don't see onboarding
    reversible do |dir|
      dir.up do
        execute "UPDATE users SET onboarding_state = 3 WHERE created_at < '#{Time.current}'"
      end
    end
  end
end
