# Gournal - HTTP Cache Implementation Context

## Overview

Gournal is a habit tracking application built with Rails 8. This document provides development context for the HTTP caching implementation using ETags and Last-Modified headers.

## ETag Caching System

### Purpose
Implemented HTTP caching to improve performance for the habit tracking interface by reducing unnecessary data transfers when habit data hasn't changed.

### Architecture

#### Core Components

**ETagGenerator Service** (`app/services/e_tag_generator.rb`)
- Generates MD5 fingerprints based on user habits and entries
- Includes user ID, year, month, habit data, entry data, and timestamps
- Returns consistent ETags for identical data sets
- Changes when any relevant data is modified

**Controller Integration** (`app/controllers/habit_entries_controller.rb`)
- Uses `fresh_when` Rails helper for HTTP cache headers
- Generates ETag and Last-Modified for each request
- Returns 304 Not Modified when client cache is fresh
- Calculates Last-Modified from most recent habit/entry timestamp

**Model Callbacks** (`app/models/habit_entry.rb`)
- HabitEntry has `belongs_to :habit, touch: true`
- Entry updates automatically touch parent habit timestamps
- Ensures ETag invalidation when entries change

### Cache Invalidation Strategy

**Automatic Invalidation Triggers:**
- Habit creation, updates, deletion, position changes
- Habit entry creation, updates, deletion
- Any timestamp change in related data

**Cross-Device Sync:**
- Stale ETags from cached devices trigger fresh data requests
- Real-time invalidation across multiple devices/tabs
- No manual cache clearing required

### Implementation Details

#### ETag Generation Algorithm
```
ETag = MD5(user_id|year|month|habits_fingerprint|entries_fingerprint|last_modified)
```

#### Cache Headers Set
- `ETag`: MD5 fingerprint of current data state
- `Last-Modified`: Most recent update timestamp
- `Cache-Control`: Standard Rails fresh_when behavior

#### Response Behavior
- **200 OK**: Fresh data with new ETag/Last-Modified
- **304 Not Modified**: Client cache is current, no body sent

### Testing Strategy

**Unit Tests** (`test/services/etag_generator_test.rb`)
- ETag consistency and uniqueness
- Data change detection
- User and month isolation
- Edge case handling

**Integration Tests** (`test/integration/habit_tracking_cache_test.rb`)
- End-to-end cache behavior
- Cross-device invalidation scenarios
- Real controller action testing
- 304 response verification

**Controller Tests** (`test/controllers/habit_entries_controller_test.rb`)
- HTTP header validation
- Cache control behavior
- Response status verification

### Performance Benefits

**Bandwidth Reduction:**
- 304 responses contain no body data
- Significant savings for habit tracking grids with many entries

**Server Load Reduction:**
- Early termination with fresh_when
- No view rendering for cached responses
- Reduced database queries for unchanged data

**User Experience:**
- Faster page loads for unchanged data
- Seamless cross-device synchronization
- Real-time updates when data changes

## Development Guidelines

### Adding Cache-Affecting Changes

When modifying data that affects the habit tracking view:

1. **Model Changes**: Ensure timestamp updates trigger properly
2. **Controller Changes**: Verify ETag generation includes new data
3. **Test Changes**: Add cache invalidation tests for new scenarios

### Cache Debugging

**Verify Cache Headers:**
```bash
curl -I http://localhost:3000/habit_entries
curl -H "If-None-Match: \"abc123\"" -I http://localhost:3000/habit_entries
```

**Check ETag Generation:**
```ruby
ETagGenerator.call(user: user, year: 2025, month: 10)
```

**Test Cache Invalidation:**
```ruby
# In rails console
user = User.first
old_etag = ETagGenerator.call(user: user, year: 2025, month: 10)
user.habits.first.touch
new_etag = ETagGenerator.call(user: user, year: 2025, month: 10)
old_etag != new_etag # Should be true
```

### Common Pitfalls

**Missing Touch Callbacks:**
- Ensure related model updates trigger timestamp changes
- Test that nested updates invalidate parent caches

**ETag Scope Issues:**
- ETags must be unique per user/month combination
- Avoid including volatile data (like Time.current)

**Test Isolation:**
- Use `travel_to` for consistent timestamps in tests
- Avoid time-dependent assertions

## File Structure

```
app/
├── controllers/
│   └── habit_entries_controller.rb    # fresh_when integration
├── models/
│   └── habit_entry.rb                 # touch: true callback
└── services/
    └── e_tag_generator.rb              # ETag generation logic

test/
├── controllers/
│   └── habit_entries_controller_test.rb # HTTP cache behavior
├── integration/
│   └── habit_tracking_cache_test.rb     # End-to-end cache testing
└── services/
    └── etag_generator_test.rb           # Unit tests for ETag logic
```

## Related Documentation

- Rails Conditional GET guide
- HTTP caching best practices
- ETag specification (RFC 7232)
- `tasks/tasks-etag-cache-solution.md` - Implementation task breakdown