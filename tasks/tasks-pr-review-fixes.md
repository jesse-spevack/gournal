# Tasks for PR Review Critical Fixes

## Tasks

- [x] 1.0 Fix Race Condition in Drag-and-Drop Position Updates
  - [x] 1.1 Add nested positions resource route in routes.rb for `PATCH /habits/positions`
  - [x] 1.2 Create new controller `Habits::PositionsController` with update action
  - [x] 1.3 Refactor `HabitPositionUpdater` to handle atomic batch updates (removed race condition)
  - [x] 1.4 Modify `inline_habit_editor_controller.js` to send single batch request to `/habits/positions`
  - [x] 1.5 Test batch update with concurrent drag-and-drop operations
  - [x] 1.6 Write controller tests for new positions controller
  - [x] 1.7 Write service tests for refactored HabitPositionUpdater
  
- [ ] 2.0 Optimize N+1 Query in Habit Creation
  - [ ] 2.1 Replace individual `create!` calls with `insert_all` in HabitsController#create
  - [ ] 2.2 Ensure timestamps (created_at, updated_at) are properly set in bulk insert
  - [ ] 2.3 Verify habit_entries are created correctly for all days of month
  - [ ] 2.4 Update existing controller tests to verify bulk creation
  - [ ] 2.5 Add performance test to confirm N+1 is resolved
  
- [ ] 3.0 Testing and Documentation
  - [ ] 3.1 Run full test suite with `bin/rails test`
  - [ ] 3.2 Run rubocop and fix any style issues with `rubocop -A`
  - [ ] 3.3 Test drag-and-drop manually with multiple habits
  - [ ] 3.4 Test habit creation for months with different day counts (28, 30, 31 days)
  - [ ] 3.5 Verify database integrity after batch position updates
  
## Relevant Files

### Files Created:
- `app/controllers/habits/positions_controller.rb` - RESTful controller for batch position updates
- `test/controllers/habits/positions_controller_test.rb` - Comprehensive controller tests (11 tests)

### Files Modified:
- `config/routes.rb` - Added namespaced positions resource with proper route ordering
- `app/services/habit_position_updater.rb` - Refactored to handle batch updates instead of single updates
- `app/controllers/habits_controller.rb` - Updated to use new batch service interface
- `app/javascript/controllers/inline_habit_editor_controller.js` - Changed to send single batch request
- `test/services/habit_position_updater_test.rb` - Completely rewritten for batch functionality (12 tests)
- `CLAUDE.md` - Added RESTful routing guidelines

### Files to Review:
- `app/services/habit_position_updater.rb` - Reference for position update logic
- `app/models/habit.rb` - Understand validations and constraints
- `test/fixtures/habits.yml` - Test data for new tests

## Notes

### Testing Commands:
```bash
# Run all tests
bin/rails test

# Run specific test files
bin/rails test test/controllers/habits_controller_test.rb
bin/rails test test/services/habit_batch_position_updater_test.rb

# Run rubocop
rubocop -A
```

### Key Considerations:
1. **Race Condition Fix**: The batch update must be atomic - all positions update in a single transaction
2. **N+1 Fix**: Use `insert_all` which generates a single INSERT statement
3. **Maintain Backwards Compatibility**: Existing single position updates should still work
4. **Database Constraints**: Respect unique index on [user_id, year, month, position]