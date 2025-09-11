# Tasks for Improved Onboarding Experience

## Tasks

- [x] 1.0 Detect and Track New User State
  - [x] 1.1 Add `onboarding_state` enum column to users table (values: not_started, habits_created, profile_created, completed, skipped)
  - [x] 1.2 Update User model with enum definition and helper methods
  - [x] 1.3 Set default onboarding_state to 'not_started' for new users
  - [x] 1.4 Modify SettingsController to pass onboarding state to view
  
- [x] 2.0 Implement Progressive Section Reveal System
  - [x] 2.1 Create conditional section rendering based on onboarding_state
  - [x] 2.2 Show only habits section when state == 'not_started'
  - [x] 2.3 Show habits + profile sections when state == 'habits_created'
  - [x] 2.4 Show habits + profile + sharing sections when state == 'profile_created'
  - [x] 2.5 Show all sections normally when state == 'completed' or 'skipped'
  - [x] 2.6 Ensure Month Setup section remains hidden until habits exist (independent of onboarding)
  
- [ ] 3.0 Create Onboarding Helper Text Components
  - [x] 3.1 Create `_onboarding_hint.html.erb` partial for reusable hint text
  - [x] 3.2 Add habit creation hint below habit list when state == 'not_started'
  - [x] 3.3 Add profile setup hint below profile section when state == 'habits_created'
  - [x] 3.4 Add sharing settings hint below sharing section when state == 'profile_created'
  - [x] 3.5 Style hints with typewriter font and subtle visual treatment
  - [x] 3.6 Add skip onboarding link/button at bottom of visible sections
  
- [ ] 4.0 Update Controllers for Onboarding State Progression
  - [ ] 4.1 Update HabitsController#create to advance from 'not_started' to 'habits_created' on first habit
  - [ ] 4.2 Update SettingsController#update to detect profile slug changes and advance to 'profile_created'
  - [ ] 4.3 Update SettingsController#update to detect sharing settings changes and advance to 'completed'
  - [ ] 4.4 Add skip_onboarding action to SettingsController to set state to 'skipped'
  - [ ] 4.5 Ensure state only advances forward (no regression to earlier states)
  - [ ] 4.6 Use Turbo to smoothly update the page after form submissions
  
- [ ] 5.0 Add Visual Styling for Onboarding State
  - [ ] 5.1 Create `_onboarding.scss` component stylesheet
  - [ ] 5.2 Style onboarding hints with appropriate spacing and typography
  - [ ] 5.3 Add subtle visual emphasis to current onboarding section
  - [ ] 5.4 Style skip link to be present but unobtrusive
  - [ ] 5.5 Ensure smooth visual flow when new sections appear after form submission
  
- [ ] 6.0 Testing and Polish
  - [ ] 6.1 Write tests for User model onboarding enum and methods
  - [ ] 6.2 Write controller tests for onboarding state progression in HabitsController
  - [ ] 6.3 Write controller tests for onboarding state progression in SettingsController
  - [ ] 6.4 Test complete flow from account creation through onboarding
  - [ ] 6.5 Verify skip functionality sets state to 'skipped'
  - [ ] 6.6 Ensure onboarding doesn't reappear for 'completed' or 'skipped' users
  - [ ] 6.7 Test that returning users see their saved progress

## Relevant Files

### Files to Create
- `db/migrate/[timestamp]_add_onboarding_state_to_users.rb` - Migration for onboarding enum
- `app/views/settings/_onboarding_hint.html.erb` - Reusable hint text partial
- `app/assets/stylesheets/components/_onboarding.scss` - Onboarding-specific styles
- `test/models/user_onboarding_test.rb` - User model onboarding tests
- `test/controllers/habits_controller_onboarding_test.rb` - Habits controller onboarding tests
- `test/controllers/settings_controller_onboarding_test.rb` - Settings controller onboarding tests

### Files to Modify
- `app/models/user.rb` - Add onboarding_state enum and helper methods
- `app/controllers/habits_controller.rb` - Update create action for onboarding progression
- `app/controllers/settings_controller.rb` - Add onboarding logic and skip action
- `app/views/settings/index.html.erb` - Add conditional rendering and onboarding elements
- `app/views/settings/_habit_list.html.erb` - Add onboarding hint for habits
- `app/views/settings/_profile_url_section.html.erb` - Add onboarding hint for profile
- `app/views/settings/_privacy_settings_section.html.erb` - Add onboarding hint for sharing
- `app/assets/stylesheets/application.scss` - Import onboarding styles
- `config/routes.rb` - Add skip_onboarding route

## Notes

- Uses existing form submissions - no custom AJAX needed
- Onboarding state updates happen in existing controller actions
- Turbo handles page updates after form submissions
- States: not_started → habits_created → profile_created → completed (or skipped)
- Each state shows exactly the sections needed for that step
- Skip link allows users to bypass guided flow
- Typewriter font (var(--font-mono)) at 11px for all onboarding text
- Minimal, aesthetically clean design approach