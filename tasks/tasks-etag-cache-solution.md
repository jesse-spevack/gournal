# Tasks for ETag HTTP Caching Solution

## Tasks

- [x] 1.0 Create ETag generation service and controller integration
  - [x] 1.1 Write failing test for ETag generation based on habit data
  - [x] 1.2 Create ETagGenerator service that builds fingerprint from user habits
  - [x] 1.3 Write failing test for controller ETag integration
  - [x] 1.4 Add ETag generation method to HabitEntriesController
  - [x] 1.5 Run tests to verify ETag generation logic

- [x] 2.0 Implement HTTP cache headers in HabitEntriesController
  - [x] 2.1 Write failing test for fresh_when behavior with matching ETag
  - [x] 2.2 Write failing test for fresh_when behavior with stale ETag
  - [x] 2.3 Implement fresh_when in HabitEntriesController#index
  - [x] 2.4 Add last_modified timestamp to ETag calculation
  - [x] 2.5 Verify HTTP headers are set correctly in controller tests

- [x] 3.0 Add cache invalidation when habit data changes
  - [x] 3.1 Write failing test for ETag change when habits are updated
  - [x] 3.2 Write failing test for ETag change when habit entries are updated
  - [x] 3.3 Ensure habit model touches affect ETag calculation
  - [x] 3.4 Verify habit_entry updates trigger ETag changes
  - [x] 3.5 Test cross-device scenario with habit updates

- [ ] 4.0 Create comprehensive test suite for ETag functionality
  - [ ] 4.1 Write unit tests for ETagGenerator service
  - [ ] 4.2 Write controller tests for HTTP cache behavior
  - [ ] 4.3 Create integration tests for 304 Not Modified responses
  - [ ] 4.4 Create integration tests for cache invalidation scenarios
  - [ ] 4.5 Add performance tests comparing 304 vs 200 response times
  - [ ] 4.6 Run rubocop -A to fix any style issues in tests

- [ ] 5.0 Manual testing and verification
  - [ ] 5.1 Test ETag headers using curl commands
  - [ ] 5.2 Verify browser Network tab shows If-None-Match headers
  - [ ] 5.3 Test cross-device sync by updating habits on mobile
  - [ ] 5.4 Verify stale tab refreshes show new data after remote changes
  - [ ] 5.5 Check browser cache behavior in dev tools Application tab

- [ ] 6.0 Documentation and project improvements
  - [ ] 6.1 Review and clean up any comments added during development
  - [ ] 6.2 Create PROJECT_CONTEXT.md with ETag implementation context
  - [ ] 6.3 Update README with cache behavior documentation
  - [ ] 6.4 Review CLAUDE.md for potential HTTP caching guidelines
  - [ ] 6.5 Suggest improvements to hooks for cache-related development
  - [ ] 6.6 Document testing patterns for HTTP cache functionality

## Relevant Files

### Files to Create
- `app/services/etag_generator.rb` - Service to generate ETags from habit data
- `test/services/etag_generator_test.rb` - Unit tests for ETag generation logic
- `test/integration/habit_tracking_cache_test.rb` - Integration tests for HTTP cache behavior
- `PROJECT_CONTEXT.md` - Development context documentation for ETag implementation

### Files to Modify
- `app/controllers/habit_entries_controller.rb` - Add fresh_when ETag functionality
- `test/controllers/habit_entries_controller_test.rb` - Add HTTP cache behavior tests
- `README.md` - Document cache behavior and performance improvements
- `CLAUDE.md` - Add HTTP caching development guidelines (if applicable)

### Files Referenced
- `app/services/habit_tracker_data_builder.rb` - Used for understanding data dependencies
- `app/models/habit.rb` - Timestamp data for ETag calculation
- `app/models/habit_entry.rb` - Entry update timestamps for cache invalidation

## Testing Commands

```bash
# Run all tests
bin/rails test

# Run specific test files
bin/rails test test/services/etag_generator_test.rb
bin/rails test test/controllers/habit_entries_controller_test.rb
bin/rails test test/integration/habit_tracking_cache_test.rb

# Run rubocop for style compliance
rubocop -A

# Manual curl testing
curl -I http://localhost:3000/habit_entries
curl -H "If-None-Match: \"abc123\"" -I http://localhost:3000/habit_entries
```

## Notes

- Follow existing service object patterns with `.call` class method
- Use ActionDispatch::IntegrationTest for controller tests
- Include time travel in tests for consistent timestamp behavior
- ETag should change when any habit or habit_entry is updated
- Focus on TDD approach - write failing tests first, then implement
- Ensure 304 responses are significantly faster than 200 responses