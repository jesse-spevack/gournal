# Tasks for Daily Reflections Implementation

## Overview
Implement inline-editable daily reflections with auto-save functionality for the habit tracker grid. Users can type reflections directly in the grid cells with typewriter font aesthetic, automatic saving, and proper truncation handling.

## Tasks

- [ ] 1.0 Backend Infrastructure Setup
  - [x] 1.1 Create DailyReflectionsController with create and update actions
  - [x] 1.2 Add nested routes under habit_entries for reflections
  - [x] 1.3 Update HabitTrackerDataBuilder to include reflections lookup
  - [x] 1.4 Add helper method to find or build reflection for specific date
  - [x] 1.5 Ensure proper error handling for AJAX requests

- [ ] 2.0 Data Layer Enhancement  
  - [ ] 2.1 Update DailyReflection model to handle find_or_create logic
  - [ ] 2.2 Add scoped finder methods for efficient reflection lookup
  - [ ] 2.3 Verify existing associations and validations are sufficient
  - [ ] 2.4 Add any missing indexes for performance

- [ ] 3.0 View Layer Integration
  - [ ] 3.1 Update habit_entries/index.html.erb to include textarea in reflection cells
  - [ ] 3.2 Add data attributes for Stimulus targeting and reflection identification
  - [ ] 3.3 Implement proper textarea sizing and responsive behavior
  - [ ] 3.4 Add CSRF token handling for AJAX requests
  - [ ] 3.5 Ensure proper form semantics and accessibility

- [ ] 4.0 JavaScript Auto-Save Implementation
  - [ ] 4.1 Create reflection_editor_controller.js Stimulus controller
  - [ ] 4.2 Implement debounced auto-save with 500ms delay
  - [ ] 4.3 Handle textarea auto-resize based on content
  - [ ] 4.4 Add focus/blur state management for truncation toggle
  - [ ] 4.5 Implement error handling and retry logic for failed saves
  - [ ] 4.6 Add optimistic updates for smooth user experience

- [ ] 5.0 CSS Styling and Visual Polish
  - [ ] 5.1 Create _reflections.scss component file
  - [ ] 5.2 Style textareas with typewriter font (Courier New)
  - [ ] 5.3 Implement single-line truncation when unfocused
  - [ ] 5.4 Add smooth transitions between focused/unfocused states
  - [ ] 5.5 Ensure mobile-friendly touch targets and sizing
  - [ ] 5.6 Integrate with existing Japanese paper aesthetic
  - [ ] 5.7 Handle placeholder styling and empty state appearance

- [ ] 6.0 Testing and Quality Assurance
  - [ ] 6.1 Write controller tests for DailyReflectionsController
  - [ ] 6.2 Add model tests for any new DailyReflection methods
  - [ ] 6.3 Manual testing across different devices and screen sizes

## Implementation Notes

**Architecture Decisions:**
- No Turbo Frames (avoiding complexity of 30+ frames)
- Single Stimulus controller with vanilla AJAX
- Debounced auto-save (500ms delay)
- CSS-based truncation with full text on focus
- Typewriter font (Courier New) for vintage aesthetic

**Key Requirements:**
- Inline editing directly in grid cells
- Auto-save on typing (no manual save button)
- Support line breaks but display single line when unfocused
- No character limits or validation
- Mobile-friendly with native keyboard
- Editable for past dates, allow pre-writing future dates

**Current State:**
- DailyReflection model exists with proper associations
- HabitTrackerDataBuilder service handles data preparation
- Grid layout already structured with reflection column placeholder
- Test infrastructure in place with minitest

## Relevant Files

### Files to Create
- `app/controllers/daily_reflections_controller.rb` - AJAX endpoints for reflection CRUD
- `app/javascript/controllers/reflection_editor_controller.js` - Stimulus controller for auto-save
- `app/assets/stylesheets/components/_reflections.scss` - Component styles
- `test/controllers/daily_reflections_controller_test.rb` - Controller test coverage

### Files to Modify
- `config/routes.rb` - Add nested reflection routes
- `app/services/habit_tracker_data_builder.rb` - Include reflections in data object
- `app/views/habit_entries/index.html.erb` - Add textarea elements to reflection cells
- `app/assets/stylesheets/application.scss` - Import new reflection styles
- `test/models/daily_reflection_test.rb` - Add tests for new model methods (if any)

### Supporting Files
- `app/models/daily_reflection.rb` - May need helper methods for find_or_create logic
- `app/models/habit_tracker_data.rb` - May need reflection accessor methods
- `test/fixtures/daily_reflections.yml` - Test data for reflection scenarios

## Testing Strategy

**Unit Tests:**
- DailyReflectionsController actions (create, update, error handling)
- DailyReflection model methods (if any new ones added)
- HabitTrackerDataBuilder reflection inclusion

**Integration Tests:**
- Full reflection creation/update flow via AJAX
- Grid rendering with existing reflections
- Error handling for invalid data

**Manual Testing Checklist:**
- [ ] Type in reflection and verify auto-save works
- [ ] Long text truncates properly when unfocused
- [ ] Textarea expands with content appropriately  
- [ ] Mobile keyboard experience is smooth
- [ ] Network failures handle gracefully
- [ ] Past dates are editable, future dates allow pre-writing
- [ ] Page refresh preserves reflection content
- [ ] Multiple rapid keystrokes don't cause issues (debouncing works)

## Implementation Order

1. Start with backend (controller, routes, data layer)
2. Update view layer with textareas and data attributes
3. Create Stimulus controller for basic functionality
4. Add CSS styling and visual polish
5. Comprehensive testing and edge case handling

This ensures a working foundation before adding complexity, following the existing TDD patterns in the codebase.