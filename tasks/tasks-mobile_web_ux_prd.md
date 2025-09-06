# Tasks for Habit Tracker Context Menu UI Revision

## Tasks

- [x] 1.0 Remove drag-and-drop UI elements
  - [x] 1.1 Remove drag handle elements from habit list view (_habit_list.html.erb)
  - [x] 1.2 Remove drag-and-drop JavaScript functionality from inline_habit_editor_controller.js
  - [x] 1.3 Clean up CSS by removing drag handle styles and drag states from _habit-list.scss
  - [x] 1.4 Remove draggable attributes and cursor styles
  - [x] 1.5 Test that habit list displays cleanly without drag handles
  
- [x] 2.0 Create context menu component
  - [x] 2.1 Create new Stimulus controller context_menu_controller.js
  - [x] 2.2 Add context menu HTML structure to _habit_list.html.erb
  - [x] 2.3 Define menu actions array (Edit Name, Move Up, Move Down, Delete Habit, Cancel)
  - [x] 2.4 Implement backdrop element for modal overlay
  - [x] 2.5 Add data attributes to track selected habit
  
- [x] 3.0 Implement interaction triggers
  - [x] 3.1 Add long-press detection for mobile (touch events with 500ms threshold)
  - [x] 3.2 Add right-click detection for desktop (contextmenu event)
  - [x] 3.3 Prevent default browser context menu
  - [x] 3.4 Store reference to selected habit when menu triggered
  - [x] 3.5 Position menu appropriately (bottom sheet mobile, near cursor desktop)
  
- [x] 4.0 Wire up context menu actions
  - [x] 4.1 Implement "Edit Name" action to trigger inline edit mode
  - [x] 4.2 Implement "Move Up" action using existing position update endpoint
  - [x] 4.3 Implement "Move Down" action using existing position update endpoint  
  - [x] 4.4 Implement "Delete Habit" action with immediate deletion
  - [x] 4.5 Implement "Cancel" action and backdrop tap to close menu
  
- [x] 5.0 Style context menu for mobile and desktop
  - [x] 5.1 Create new _context-menu.scss component file
  - [x] 5.2 Style mobile menu as bottom sheet with rounded corners
  - [x] 5.3 Style desktop menu as compact dropdown
  - [x] 5.4 Apply 44px minimum touch targets for mobile
  - [x] 5.5 Add hover states for desktop menu items
  - [x] 5.6 Style backdrop with semi-transparent overlay
  
- [x] 6.0 Add animations and transitions
  - [x] 6.1 Implement slide-up animation for mobile (300ms ease-out)
  - [x] 6.2 Implement fade-in animation for desktop (150ms ease-out)
  - [x] 6.3 Add backdrop fade-in animation
  - [x] 6.4 Implement smooth list reordering transitions (200ms)
  - [x] 6.5 Add swipe-down gesture to dismiss mobile menu
  
- [x] 7.0 Testing and cleanup
  - [x] 7.1 Test long-press on mobile devices/emulator
  - [x] 7.2 Test right-click on desktop
  - [x] 7.3 Verify all menu actions work correctly
  - [x] 7.4 Test keyboard navigation (Escape to close)
  - [x] 7.5 Run rubocop -A to fix any style issues
  - [x] 7.6 Write controller tests for new/modified endpoints if needed
  - [x] 7.7 Manual cross-browser testing

## Relevant Files

### Files to Modify
- `app/views/settings/_habit_list.html.erb` - Remove drag handles, add context menu HTML
- `app/javascript/controllers/inline_habit_editor_controller.js` - Remove drag-and-drop code
- `app/assets/stylesheets/components/_habit-list.scss` - Remove drag-related styles
- `app/assets/stylesheets/application.scss` - Import new context menu styles
- `app/controllers/habits_controller.rb` - Ensure delete action works via AJAX

### Files to Create  
- `app/javascript/controllers/context_menu_controller.js` - New controller for context menu
- `app/assets/stylesheets/components/_context-menu.scss` - Context menu styles

### Test Files
- `test/controllers/habits_controller_test.rb` - Update tests for delete action

## Notes

### Testing Commands
```bash
# Run controller tests
bin/rails test test/controllers/habits_controller_test.rb

# Run all tests
bin/rails test

# Fix code style
rubocop -A

# Start dev server for manual testing
bin/dev
```

### Key Implementation Details
- Maintain existing inline edit functionality (tap/click habit name)
- Reuse existing `/habits/positions` endpoint for reordering
- Follow design token system for all styling
- Ensure graceful degradation for devices with both touch and mouse
- Keep minimalist aesthetic with text-only menu items (no icons)