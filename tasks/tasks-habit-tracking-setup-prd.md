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
  
- [ ] 4.0 "Set Up Next Month" Feature
  - [ ] 4.1 Create HabitCopyService with self.call pattern
  - [ ] 4.2 Generate MonthSetupsController
  - [ ] 4.3 Add routes for month setup actions
  - [ ] 4.4 Add "Set up next month" section to settings
  - [ ] 4.5 Create modal/dropdown with "Copy" and "Start fresh" options
  - [ ] 4.6 Implement copy_from_current using HabitCopyService
  - [ ] 4.7 Implement start_fresh action
  - [ ] 4.8 Add future month validation
  - [ ] 4.9 Create month_setup Stimulus controller
  - [ ] 4.10 Style month setup UI
  - [ ] 4.11 Write tests for service and controller
  - [ ] 4.12 Manual test month setup flow
  
- [ ] 5.0 Public Profile Sharing Feature
  - [ ] 5.1 Generate migration for slug and privacy fields
  - [ ] 5.2 Update User model with slug/privacy validations
  - [ ] 5.3 Generate PublicProfilesController
  - [ ] 5.4 Add catch-all route for /:slug
  - [ ] 5.5 Add slug input to settings profile section
  - [ ] 5.6 Add privacy toggles (habits/reflections) to settings
  - [ ] 5.7 Create privacy_settings Stimulus controller
  - [ ] 5.8 Implement public profile show action with privacy checks
  - [ ] 5.9 Create public_profiles/show.html.erb (read-only view)
  - [ ] 5.10 Add "Create Account" button for non-auth users
  - [ ] 5.11 Remove ENV["FIRST_USER"] hardcoding
  - [ ] 5.12 Write tests for privacy and public access
  - [ ] 5.13 Manual test sharing flow end-to-end
  
- [ ] 6.0 Polish and Integration
  - [ ] 6.1 Create consistent hand-drawn icon set
  - [ ] 6.2 Add loading states for all async operations
  - [ ] 6.3 Implement comprehensive error handling
  - [ ] 6.4 Write end-to-end integration tests
  - [ ] 6.5 Performance testing (<500ms load)
  - [ ] 6.6 Accessibility audit
  - [ ] 6.7 Final rubocop -A and full test suite

## Relevant Files

### Files to Create
- `db/migrate/[timestamp]_add_public_sharing_to_users.rb` - Migration for slug and privacy fields
- `app/controllers/settings_controller.rb` - Main settings page controller
- `app/controllers/habits_controller.rb` - CRUD operations for habits
- `app/controllers/month_setups_controller.rb` - Month setup actions
- `app/controllers/public_profiles_controller.rb` - Public profile viewing
- `app/services/habit_copy_service.rb` - Service for copying habits between months
- `app/views/settings/index.html.erb` - Settings page layout
- `app/views/settings/_habit_item.html.erb` - Individual habit row partial
- `app/views/settings/_settings_button.html.erb` - Settings button partial
- `app/views/public_profiles/show.html.erb` - Public profile view
- `app/javascript/controllers/habit_management_controller.js` - Inline editing and reordering
- `app/javascript/controllers/month_setup_controller.js` - Month setup interactions
- `app/javascript/controllers/privacy_settings_controller.js` - Privacy toggle handling
- `app/assets/stylesheets/components/_settings.scss` - Settings page styles
- `app/assets/stylesheets/components/_settings-button.scss` - Button styles
- `test/controllers/settings_controller_test.rb` - Settings controller tests
- `test/controllers/habits_controller_test.rb` - Habits CRUD tests
- `test/controllers/month_setups_controller_test.rb` - Month setup tests
- `test/controllers/public_profiles_controller_test.rb` - Public profile tests
- `test/services/habit_copy_service_test.rb` - Service unit tests
- `test/models/user_test.rb` - Updated with slug/privacy tests

### Files to Modify
- `app/models/user.rb` - Add slug and privacy validations
- `app/models/habit.rb` - Ensure soft-delete scope works
- `app/controllers/application_controller.rb` - Update authentication helpers
- `app/controllers/habit_entries_controller.rb` - Remove ENV["FIRST_USER"] hardcoding
- `app/views/habit_entries/index.html.erb` - Add settings button
- `app/assets/stylesheets/application.scss` - Import new component styles
- `config/routes.rb` - Add settings, habits, and public profile routes
- `test/test_helper.rb` - Add helper methods for new features

## Testing Approach
- Each task includes its own tests (unit and integration)
- Follow TDD approach: write tests first, then implementation
- Manual testing on Pixel 8 Pro viewport (412x915px)
- Test commands: `bin/rails test`
- Run `rubocop -A` after each implementation phase