# Tasks for Browser-Detected Timezone Support

## Overview
Implement automatic timezone detection using the browser's `Intl.DateTimeFormat()` API to ensure the "today" indicator dot appears on the correct day for users in different timezones. Store timezone in cookies, load into `Current` for request-scoped access, and provide a `current_date` helper for views.

## Tasks

- [x] 1.0 Add timezone attribute to Current model and configure application-wide timezone handling
  - [x] 1.1 Add `timezone` attribute to `app/models/current.rb`
  - [x] 1.2 Add `timezone` getter method with 'UTC' fallback in `Current` model
  - [x] 1.3 Add `set_timezone` before_action in `ApplicationController`
  - [x] 1.4 Implement `set_timezone` method to read from cookie and set `Current.timezone`

- [ ] 2.0 Create Stimulus controller for browser timezone detection
  - [x] 2.1 Create `app/javascript/controllers/timezone_controller.js`
  - [x] 2.2 Implement `connect()` method to detect timezone using `Intl.DateTimeFormat().resolvedOptions().timeZone`
  - [x] 2.3 Store detected timezone in `sessionStorage` for client-side tracking
  - [x] 2.4 Implement `sendTimezoneToServer()` method to POST timezone to `/timezone` endpoint
  - [x] 2.5 Add CSRF token handling in fetch request headers
  - [x] 2.6 Track sent timezone in `sessionStorage` to avoid redundant requests
  - [x] 2.7 Add `data-controller="timezone"` to `<body>` tag in `app/views/layouts/application.html.erb`

- [ ] 3.0 Create TimezoneController for storing user timezone preferences
  - [ ] 3.1 Create `app/controllers/timezone_controller.rb`
  - [ ] 3.2 Implement `create` action to handle POST requests
  - [ ] 3.3 Add timezone validation using `ActiveSupport::TimeZone::MAPPING.value?`
  - [ ] 3.4 Store valid timezone in both session and persistent cookie (1 year expiry)
  - [ ] 3.5 Set `Current.timezone` immediately in the response
  - [ ] 3.6 Return appropriate HTTP status codes (200 for success, 422 for invalid)
  - [ ] 3.7 Add `post '/timezone', to: 'timezone#create'` route in `config/routes.rb`

- [ ] 4.0 Add current_date helper to ApplicationHelper and update views
  - [ ] 4.1 Create `current_date` helper method in `app/helpers/application_helper.rb`
  - [ ] 4.2 Implement helper to use `Time.use_zone(Current.timezone) { Date.current }`
  - [ ] 4.3 Update `app/views/shared/_habit_grid_rows.html.erb` to use `current_date` helper
  - [ ] 4.4 Replace `Date.current.day` with `current_date.day` for today calculation
  - [ ] 4.5 Replace `Date.current.year` and `Date.current.month` with `current_date.year` and `current_date.month`
  - [ ] 4.6 Review and update any other views using `Date.current` if needed

- [ ] 5.0 Testing and validation
  - [ ] 5.1 Create `test/controllers/timezone_controller_test.rb`
  - [ ] 5.2 Write test for storing valid timezone in session and cookie
  - [ ] 5.3 Write test for rejecting invalid timezone
  - [ ] 5.4 Write test for verifying `Current.timezone` is set
  - [ ] 5.5 Create `test/helpers/application_helper_test.rb` (if not exists)
  - [ ] 5.6 Write test for `current_date` helper with different timezones
  - [ ] 5.7 Test that helper falls back to UTC when no timezone set
  - [ ] 5.8 Run `rubocop -A` to fix any style issues
  - [ ] 5.9 Run full test suite to ensure no regressions
  - [ ] 5.10 Manual testing: clear cookies, reload page, verify timezone is detected and stored
  - [ ] 5.11 Manual testing: verify "today" dot appears on correct day in Mountain Time

## Relevant Files

### Files to Create
- `app/javascript/controllers/timezone_controller.js` - Stimulus controller for browser timezone detection
- `app/controllers/timezone_controller.rb` - Rails controller for storing timezone preferences
- `test/controllers/timezone_controller_test.rb` - Tests for TimezoneController
- `test/helpers/application_helper_test.rb` - Tests for current_date helper (if not exists)

### Files to Modify
- `app/models/current.rb` - Add timezone attribute and getter method
- `app/controllers/application_controller.rb` - Add set_timezone before_action
- `app/helpers/application_helper.rb` - Add current_date helper method
- `app/views/layouts/application.html.erb` - Add timezone controller to body tag
- `app/views/shared/_habit_grid_rows.html.erb` - Replace Date.current with current_date helper
- `config/routes.rb` - Add POST /timezone route

### Related Files (Reference Only)
- `app/models/current.rb` - Existing Current model pattern (already has session attribute)
- `app/controllers/concerns/authentication.rb` - Example of cookie usage pattern
- `app/javascript/controllers/checkbox_controller.js` - Example Stimulus controller pattern

## Testing Commands

```bash
# Run specific tests
bin/rails test test/controllers/timezone_controller_test.rb
bin/rails test test/helpers/application_helper_test.rb

# Run all tests
bin/rails test

# Fix style issues
rubocop -A

# Manual browser testing
# 1. Clear cookies/sessionStorage
# 2. Load app in browser
# 3. Check browser console for timezone detection
# 4. Verify cookie set: document.cookie
# 5. Verify "today" dot on correct day
```

## Notes

- Cookie strategy: Store in persistent cookie (1 year) for cross-session persistence
- Fallback: If JS disabled or timezone not set, defaults to UTC
- Validation: Only accept timezones in `ActiveSupport::TimeZone::MAPPING`
- Browser API: `Intl.DateTimeFormat().resolvedOptions().timeZone` returns IANA timezone string (e.g., "America/Denver")
- Current pattern: Follows existing `Current.session` and `Current.user` architecture
- Session storage: Used client-side only to track if timezone already sent to server
- Testing: Use `Time.use_zone` in tests to simulate different timezones
