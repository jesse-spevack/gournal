# Tasks for Habit Order Bugs Fix

## Overview
Fix bugs in habit re-ordering functionality where position updates ignore target month parameters and settings view doesn't properly set year/month context.

## Bugs to Fix
1. **Bug #1**: `HabitPositionUpdater` ignores `target_year` and `target_month` parameters and always uses current month
2. **Bug #2**: Settings view doesn't populate `data-target-year` and `data-target-month` attributes for context menu

## Tasks

- [x] 1.0 Write failing tests that expose the current buggy behavior
  - [x] 1.1 Add test in `habit_position_updater_test.rb` to verify service accepts target year/month params
  - [x] 1.2 Add test to verify updating positions for a specific non-current month (e.g., update February habits while in January)
  - [x] 1.3 Add test to verify that only habits from the target month are affected, not current month habits
  - [x] 1.4 Add controller test in `positions_controller_test.rb` to verify target_year and target_month params are passed through
  - [x] 1.5 Run tests to confirm they fail (exposing the bug)

- [ ] 2.0 Update HabitPositionUpdater service to accept and use target year/month parameters
  - [x] 2.1 Add optional `year:` and `month:` keyword arguments to `.call` method signature (default to nil)
  - [x] 2.2 Add optional `year:` and `month:` to `initialize` method
  - [x] 2.3 Update `habits_scope` method to use provided year/month or fall back to current date
  - [x] 2.4 Ensure the logic properly handles both cases: explicit year/month and default current date

- [ ] 3.0 Update Habits::PositionsController to pass target year/month to service
  - [ ] 3.1 Extract `target_year` and `target_month` from params in the `update` action
  - [ ] 3.2 Pass `year:` and `month:` to `HabitPositionUpdater.call` (only if present in params)
  - [ ] 3.3 Handle cases where params are missing (should fall back to current month behavior)

- [ ] 4.0 Update SettingsController to provide year/month context variables
  - [ ] 4.1 Set `@target_year = current_date.year` in the `index` action
  - [ ] 4.2 Set `@target_month = current_date.month` in the `index` action
  - [ ] 4.3 Set same variables in the `update` action (within the else block for error rendering)
  - [ ] 4.4 Verify the `_habit_list.html.erb` partial correctly receives these variables

- [ ] 5.0 Verify all tests pass and manually test the fix
  - [ ] 5.1 Run `bin/rails test test/services/habit_position_updater_test.rb` - all tests should pass
  - [ ] 5.2 Run `bin/rails test test/controllers/habits/positions_controller_test.rb` - all tests should pass
  - [ ] 5.3 Run `rubocop -A` to fix any style issues
  - [ ] 5.4 Manually test reordering habits in settings view (should work for current month)
  - [ ] 5.5 Manually test that future month habit creation and setup works correctly

## Relevant Files

### Files to Modify
- `app/services/habit_position_updater.rb` - Add year/month parameter support
- `app/controllers/habits/positions_controller.rb` - Pass target year/month params to service
- `app/controllers/settings_controller.rb` - Set @target_year and @target_month variables
- `test/services/habit_position_updater_test.rb` - Add failing tests for target month functionality
- `test/controllers/habits/positions_controller_test.rb` - Add tests for controller param passing

### Files Referenced (No Changes)
- `app/views/settings/_habit_list.html.erb` - Already uses @target_year/@target_month (lines 3-4)
- `app/javascript/controllers/context_menu_controller.js` - Already sends target year/month in updatePositions (lines 604-618)
- `app/models/habit.rb` - Position validation and scopes

## Testing Commands

```bash
# Run specific test files
bin/rails test test/services/habit_position_updater_test.rb
bin/rails test test/controllers/habits/positions_controller_test.rb

# Run all tests
bin/rails test

# Fix style issues
rubocop -A
```

## Notes

- The JavaScript already sends `target_year` and `target_month` in the AJAX request (context_menu_controller.js:604-618)
- The view partial already expects `@target_year` and `@target_month` variables (_habit_list.html.erb:3-4)
- The main issue is that the backend ignores these parameters
- This fix will enable proper habit reordering for any month, not just the current one
- Maintains backward compatibility by defaulting to current month when params are missing
