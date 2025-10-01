# Tasks for Fix Missing Habit Entries Bug

## Problem Statement
When users copy habits to a new month, only `Habit` records are created but not `HabitEntry` records. This causes habit headers to appear on the tracker page but no checkboxes are rendered.

## Solution Approach
1. **Auto-heal**: Automatically create missing habit entries when the tracker loads (fixes existing users)
2. **Prevention**: Create habit entries when copying habits (prevents future issues)

## Tasks

- [x] 1.0 Extract habit entry creation logic into shared service
  - [x] 1.1 Create `HabitEntryCreator` service following existing service pattern (class method `self.call`)
  - [x] 1.2 Implement `create_entries_for_month` method that takes habit, year, month parameters
  - [x] 1.3 Include random style assignment logic (checkbox_style and check_style based on habit.check_type)
  - [x] 1.4 Use `insert_all` for bulk creation with timestamps
  - [x] 1.5 Refactor `HabitCreator` to use the new `HabitEntryCreator` service
  - [x] 1.6 Run `rubocop -A` and verify no style issues

- [x] 2.0 Implement auto-heal in HabitTrackerDataBuilder
  - [x] 2.1 Add private method `ensure_habit_entries_exist(habits)` in `HabitTrackerDataBuilder`
  - [x] 2.2 Iterate through habits and identify missing days for each habit
  - [x] 2.3 Call `HabitEntryCreator` to bulk create missing entries
  - [x] 2.4 Reload habit associations if entries were created
  - [x] 2.5 Call auto-heal method from `fetch_habits` before returning habits
  - [x] 2.6 Run `rubocop -A` and verify no style issues

- [x] 3.0 Fix HabitCopyService to create habit entries
  - [x] 3.1 Modify `copy_habits` method to call `HabitEntryCreator` after saving each copied habit
  - [x] 3.2 Pass target_year and target_month to `HabitEntryCreator`
  - [x] 3.3 Verify entries are created for all days in target month
  - [x] 3.4 Run `rubocop -A` and verify no style issues

- [x] 4.0 Add comprehensive tests for both solutions
  - [x] 4.1 Create `test/services/habit_entry_creator_test.rb` with tests for:
    - [x] Class method delegation
    - [x] Creating entries for full month (28, 30, 31 days)
    - [x] Random style assignment (checkbox_style and check_style)
    - [x] Check_style matches habit.check_type (x_marks vs blots)
    - [x] All entries default to completed: false
  - [x] 4.2 Update `test/services/habit_tracker_data_builder_test.rb` with auto-heal tests:
    - [x] Test that missing entries are created when habits exist without entries
    - [x] Test that no duplicate entries are created if some already exist
    - [x] Test that existing entries are not modified
    - [x] Test performance with multiple habits missing entries
  - [x] 4.3 Update `test/services/habit_copy_service_test.rb` to verify entries are created:
    - [x] Modify existing tests to assert habit_entries are created
    - [x] Test that all days in target month have entries
    - [x] Test entries have proper styles assigned
    - [x] Test December to January transition creates correct number of entries
  - [x] 4.4 Update `test/services/habit_creator_test.rb` if needed to verify refactoring
  - [x] 4.5 Run full test suite: `bin/rails test`
  - [x] 4.6 Verify all tests pass

- [ ] 5.0 Manual testing and verification
  - [ ] 5.1 Test auto-heal: Create a habit directly in console without entries, then load tracker page
  - [ ] 5.2 Verify checkboxes appear for the habit created in 5.1
  - [ ] 5.3 Test habit copying: Copy habits from previous month via UI
  - [ ] 5.4 Verify all checkboxes appear immediately in new month
  - [ ] 5.5 Test edge case: Copy habits from December to January
  - [ ] 5.6 Check console/logs for any errors or warnings
  - [ ] 5.7 Verify existing data is not affected (no duplicate entries created)

## Relevant Files

### New Files to Create
- `app/services/habit_entry_creator.rb` - Shared service for creating habit entries with random styles
- `test/services/habit_entry_creator_test.rb` - Unit tests for HabitEntryCreator service

### Files to Modify
- `app/services/habit_tracker_data_builder.rb` - Add auto-heal logic to ensure entries exist
- `app/services/habit_copy_service.rb` - Create habit entries when copying habits
- `app/services/habit_creator.rb` - Refactor to use new HabitEntryCreator service
- `test/services/habit_tracker_data_builder_test.rb` - Add tests for auto-heal behavior
- `test/services/habit_copy_service_test.rb` - Update tests to verify entries are created
- `test/services/habit_creator_test.rb` - Update if refactoring changes behavior

## Technical Notes

### Existing Patterns to Follow
- Services use `self.call` class method pattern that delegates to instance
- Bulk inserts use `Model.insert_all(array_of_hashes)` with timestamps
- Random styles selected from enum keys using `.sample`
- Check styles filtered by prefix: `x_style_` for x_marks, `blot_style_` for blots

### Key Implementation Details
1. **HabitEntryCreator**: Should be generic enough to create entries for any habit/year/month combination
2. **Auto-heal**: Must be efficient (single bulk insert per habit) and idempotent (don't create duplicates)
3. **Prevention**: Integrate seamlessly into existing copy flow without breaking current behavior

### Testing Commands
```bash
# Run specific test files
bin/rails test test/services/habit_entry_creator_test.rb
bin/rails test test/services/habit_tracker_data_builder_test.rb
bin/rails test test/services/habit_copy_service_test.rb

# Run all service tests
bin/rails test test/services/

# Run full test suite
bin/rails test

# Style checking
rubocop -A
```

## Success Criteria
- [ ] All existing tests pass
- [ ] All new tests pass
- [ ] Rubocop has no violations
- [ ] Existing habits without entries automatically get entries when tracker loads
- [ ] Copying habits to new month creates entries for all days
- [ ] No duplicate entries are created
- [ ] Manual testing confirms checkboxes appear correctly
