# Tasks for Habit Tracking Setup

## Overview
Implementation tasks for comprehensive habit management system including settings interface, month-to-month carryover, and public sharing capabilities.

## Tasks

- [x] 1.0 Basic Settings Page Access
  - [x] 1.1 Generate SettingsController (`bin/rails generate controller Settings`)
  - [x] 1.2 Add authenticated route for settings
  - [x] 1.3 Create basic settings/index.html.erb with three section placeholders
  - [x] 1.4 Add hand-drawn settings button icon to assets (Using existing partial instead)
  - [x] 1.5 Add settings button to habit_entries/index.html.erb (top-right)
  - [x] 1.6 Style settings page and button with bullet journal aesthetic
  - [x] 1.7 Write controller test for authentication
  - [x] 1.8 Manual test settings access on mobile (412x915px)
  
- [x] 2.0 Bullet Journal Style Habits Management
  - [x] 2.1 Generate HabitsController with create action
  - [x] 2.2 Add route for creating habits
  - [x] 2.3 Add "Add Habit" form to settings page (name input + button) - REPLACED
  - [x] 2.4 Implement create action with auto-position and HabitEntry generation
  - [x] 2.5 Create add_habit Stimulus controller for form submission - REPLACED
  - [x] 2.6 Style the add habit form with journal aesthetic - REPLACED
  - [x] 2.7 Write tests for habit creation
  - [x] 2.8 Manual test: create habit and verify it appears in tracker
  - [x] 2.9 Refactor to bullet journal list-style interface
  - [x] 2.10 Update SettingsController to fetch existing habits
  - [x] 2.11 Create _habit_list.html.erb partial with bullet points
  - [x] 2.12 Replace add_habit Stimulus with inline_habit_editor controller
  - [x] 2.13 Style habit list with bullet journal aesthetic
  - [x] 2.14 Add update and destroy routes for habits
  - [x] 2.15 Implement inline editing for existing habits
  - [x] 2.16 Implement soft delete (set active: false)
  - [x] 2.17 Update tests for new interface
  - [x] 2.18 Manual test: bullet journal workflow on mobile
  
- [x] 3.0 Reorder Habits Feature
  - [x] 3.1 Add reorder action to HabitsController (integrated into update action)
  - [x] 3.2 Add route for reordering habits (uses existing PATCH /habits/:id)
  - [x] 3.3 Enhance habit_management controller with drag-and-drop (Stimulus)
  - [x] 3.4 Add drag handles to habit items
  - [x] 3.5 Implement position update logic (HabitPositionUpdater service)
  - [x] 3.6 Add visual feedback during drag
  - [x] 3.7 Write tests for reordering (HabitPositionUpdater service tests)
  - [x] 3.8 Manual test drag-and-drop on mobile touch
  
- [x] 4.0 "Set Up Next Month" Feature
  - [x] 4.1 Create HabitCopyService with self.call pattern
  - [x] 4.2 Generate MonthSetupsController
    - [x] 4.2.1 Create controller with create action
    - [x] 4.2.2 Handle "copy" strategy → redirect to habit tracker for target month
    - [x] 4.2.3 Handle "fresh" strategy → redirect to habits/new/:year_month
    - [x] 4.2.4 Add month setup parameter validation
  - [x] 4.3 Add routes for month setup actions
    - [x] 4.3.1 POST /month_setups route to MonthSetupsController#create
    - [x] 4.3.2 Verify habits/new/:year_month route exists (from task 5.1)
  - [x] 4.4 Add "Set up next month" section to settings
  - [x] 4.5 Create month setup UI with exclusive checkboxes
    - [x] 4.5.1 Replace placeholder with checkbox form using checkbox_helper
    - [x] 4.5.2 "Copy current habits" checkbox with description
    - [x] 4.5.3 "Start fresh" checkbox with description  
    - [x] 4.5.4 Dynamic month name (e.g., "Set up October")
    - [ ] 4.5.5 Conditional rendering if target month already has habits
    - [x] 4.5.6 Add help button (?) linking to /help/next-month-setup
  - [x] 4.6 Implement copy_from_current using HabitCopyService
  - [x] 4.7 Implement start_fresh redirect logic (no service needed)
  - [x] 4.8 Help System Restructuring
    - [x] 4.8.1 Move /settings/help to /help/manage-habits
    - [x] 4.8.2 Create /help/next-month-setup route and controller action
    - [x] 4.8.3 Update existing help button link in manage habits section
    - [x] 4.8.4 Create comprehensive next-month-setup help content
    - [x] 4.8.5 Maintain bullet journal aesthetic in help pages
  - [x] 4.9 Create month_setup Stimulus controller
    - [x] 4.9.1 Handle exclusive checkbox behavior (checking one unchecks other)
    - [x] 4.9.2 Trigger randomized X marks on checkbox interactions  
    - [x] 4.9.3 Form validation before submission
  - [x] 4.10 Style month setup UI
    - [x] 4.10.1 Integrate with existing settings page styling
    - [x] 4.10.2 Consistent spacing and typography
    - [x] 4.10.3 Proper checkbox alignment and descriptions
    - [x] 4.10.4 Submit button styling matching settings aesthetic
  - [x] 4.11 Write tests for service and controller
    - [x] 4.11.1 MonthSetupsController tests for both strategies
    - [x] 4.11.2 Help controller tests for new routes
    - [x] 4.11.3 Integration tests for complete flow
  - [ ] 4.12 Manual test month setup flow
    - [ ] 4.12.1 Test copy flow: settings → copy → target month tracker
    - [ ] 4.12.2 Test fresh flow: settings → fresh → habits/new → add habits → tracker
    - [ ] 4.12.3 Test help system: both help buttons work correctly
    - [ ] 4.12.4 Test edge cases: existing target month habits, validation errors
    - [ ] 4.12.5 Cross-browser testing of checkbox interactions
  
- [x] 5.0 Habit Management Flow Improvements
  - [x] 5.1 Add route for habits/new/:year_month (e.g. habits/new/2025-10)
  - [x] 5.2 Update HabitsController#new to accept year_month parameter
  - [x] 5.3 Create habits/new.html.erb that reuses settings _habit_list partial
  - [x] 5.4 Update MonthSetupsController to redirect "start fresh" directly to habits/new
  - [x] 5.5 Add redirect logic in HabitEntriesController#index for empty months
  - [x] 5.6 Update habits/new view with appropriate back button logic
  - [x] 5.7 Style habits/new page to match settings aesthetic
  - [x] 5.8 Write tests for new routing and redirect logic
  - [x] 5.9 Manual test the complete flow: start fresh → habits/new → add habits → view tracker
  - [x] 5.10 **CRITICAL**: Fixed drag-and-drop functionality - resolved desktop HTML5 drag API implementation and race condition causing position updates to not persist when navigating quickly. Both mobile touch and desktop drag now work reliably.
  - [x] 5.11 **UI FIXES**: Complete drag-and-drop UI restoration - made drag handles always visible, removed habit name underlines on hover, added missing data attributes for year/month targeting, fixed test capitalization to use sentence case consistently.
  - [x] 5.12 **WORKFLOW**: Added git workflow guidelines to CLAUDE.md - require feature branches, frequent commits, and atomic changes with ~100 line commit limit.
  
- [ ] 6.0 Public Profile Sharing Feature
  - [ ] 6.1 Generate migration for slug and privacy fields
  - [ ] 6.2 Update User model with slug/privacy validations
  - [ ] 6.3 Generate PublicProfilesController
  - [ ] 6.4 Add catch-all route for /:slug
  - [ ] 6.5 Add slug input to settings profile section
  - [ ] 6.6 Add privacy toggles (habits/reflections) to settings
  - [ ] 6.7 Create privacy_settings Stimulus controller
  - [ ] 6.8 Implement public profile show action with privacy checks
  - [ ] 6.9 Create public_profiles/show.html.erb (read-only view)
  - [ ] 6.10 Add "Create Account" button for non-auth users
  - [ ] 6.11 Remove ENV["FIRST_USER"] hardcoding
  - [ ] 6.12 Write tests for privacy and public access
  - [ ] 6.13 Manual test sharing flow end-to-end
  
- [ ] 7.0 Polish and Integration
  - [ ] 7.1 Create consistent hand-drawn icon set
  - [ ] 7.2 Add loading states for all async operations
  - [ ] 7.3 Implement comprehensive error handling
  - [ ] 7.4 Write end-to-end integration tests
  - [ ] 7.5 Performance testing (<500ms load)
  - [ ] 7.6 Accessibility audit
  - [ ] 7.7 Final rubocop -A and full test suite

## Relevant Files

### Files to Create
- `db/migrate/[timestamp]_add_public_sharing_to_users.rb` - Migration for slug and privacy fields
- `app/controllers/settings_controller.rb` - Main settings page controller (Created)
- `app/controllers/habits_controller.rb` - CRUD operations for habits (Created)
- `app/controllers/month_setups_controller.rb` - Month setup actions (Created)
- `app/controllers/help_controller.rb` - Help pages controller (Created)
- `app/controllers/public_profiles_controller.rb` - Public profile viewing
- `app/services/habit_copy_service.rb` - Service for copying habits between months (Created)
- `app/services/month_setup_service.rb` - Service for month setup operations (Created)
- `app/views/settings/index.html.erb` - Settings page layout (Created)
- `app/views/settings/_habit_item.html.erb` - Individual habit row partial (Created)
- `app/views/settings/_settings_button.html.erb` - Settings button partial (Created)
- `app/views/help/manage_habits.html.erb` - Help page for habit management (Created)
- `app/views/help/next_month_setup.html.erb` - Help page for next month setup (Created)
- `app/views/settings/_month_setup_section.html.erb` - Month setup form partial (Created)
- `app/views/habits/new.html.erb` - Habit creation page for new months (Created)
- `app/views/public_profiles/show.html.erb` - Public profile view
- `app/javascript/controllers/habit_management_controller.js` - Inline editing and reordering (Created)
- `app/javascript/controllers/month_setup_controller.js` - Month setup interactions (Created)
- `app/javascript/controllers/privacy_settings_controller.js` - Privacy toggle handling
- `app/assets/stylesheets/components/_settings.scss` - Settings page styles (Created)
- `app/assets/stylesheets/components/_settings-button.scss` - Button styles (Created)
- `test/controllers/settings_controller_test.rb` - Settings controller tests (Created)
- `test/controllers/habits_controller_test.rb` - Habits CRUD tests (Created)
- `test/controllers/month_setups_controller_test.rb` - Month setup tests (Created)
- `test/controllers/help_controller_test.rb` - Help controller tests (Created)
- `test/controllers/public_profiles_controller_test.rb` - Public profile tests
- `test/services/habit_copy_service_test.rb` - Service unit tests (Created)
- `test/services/month_setup_service_test.rb` - Month setup service tests (Created)
- `test/models/user_test.rb` - Updated with slug/privacy tests

### Files to Modify
- `app/models/user.rb` - Add slug and privacy validations
- `app/models/habit.rb` - Ensure soft-delete scope works (Modified)
- `app/controllers/application_controller.rb` - Update authentication helpers (Modified)
- `app/controllers/habit_entries_controller.rb` - Remove ENV["FIRST_USER"] hardcoding (Modified)
- `app/views/habit_entries/index.html.erb` - Add settings button (Modified)
- `app/assets/stylesheets/application.scss` - Import new component styles (Modified)
- `config/routes.rb` - Add settings, habits, month_setups, help, and public profile routes (Modified)
- `test/test_helper.rb` - Add helper methods for new features (Modified)
- `app/helpers/checkbox_helper.rb` - Added X marks JSON helper (Modified)

## Testing Approach
- Each task includes its own tests (unit and integration)
- Follow TDD approach: write tests first, then implementation
- Manual testing on Pixel 8 Pro viewport (412x915px)
- Test commands: `bin/rails test`
- Run `rubocop -A` after each implementation phase