# Tasks for Habit Tracker Context Menu UI Revision

## Tasks

- [ ] 1.0 Remove drag-and-drop UI elements
  - [x] 1.1 Remove drag handle elements from habit list view (_habit_list.html.erb)
  - [x] 1.2 Remove drag-and-drop JavaScript functionality from inline_habit_editor_controller.js
  - [x] 1.3 Clean up CSS by removing drag handle styles and drag states from _habit-list.scss
  - [x] 1.4 Remove draggable attributes and cursor styles
  - [x] 1.5 Test that habit list displays cleanly without drag handles
  
- [ ] 2.0 Create context menu component
  - [ ] 2.1 Create new Stimulus controller context_menu_controller.js
  - [ ] 2.2 Add context menu HTML structure to _habit_list.html.erb
  - [ ] 2.3 Define menu actions array (Edit Name, Move Up, Move Down, Delete Habit, Cancel)
  - [ ] 2.4 Implement backdrop element for modal overlay
  - [ ] 2.5 Add data attributes to track selected habit
  
- [ ] 3.0 Implement interaction triggers
  - [ ] 3.1 Add long-press detection for mobile (touch events with 500ms threshold)
  - [ ] 3.2 Add right-click detection for desktop (contextmenu event)
  - [ ] 3.3 Prevent default browser context menu
  - [ ] 3.4 Store reference to selected habit when menu triggered
  - [ ] 3.5 Position menu appropriately (bottom sheet mobile, near cursor desktop)
  
- [ ] 4.0 Wire up context menu actions
  - [ ] 4.1 Implement "Edit Name" action to trigger inline edit mode
  - [ ] 4.2 Implement "Move Up" action using existing position update endpoint
  - [ ] 4.3 Implement "Move Down" action using existing position update endpoint  
  - [ ] 4.4 Implement "Delete Habit" action with immediate deletion
  - [ ] 4.5 Implement "Cancel" action and backdrop tap to close menu
  
- [ ] 5.0 Style context menu for mobile and desktop
  - [ ] 5.1 Create new _context-menu.scss component file
  - [ ] 5.2 Style mobile menu as bottom sheet with rounded corners
  - [ ] 5.3 Style desktop menu as compact dropdown
  - [ ] 5.4 Apply 44px minimum touch targets for mobile
  - [ ] 5.5 Add hover states for desktop menu items
  - [ ] 5.6 Style backdrop with semi-transparent overlay
  
- [ ] 6.0 Add animations and transitions
  - [ ] 6.1 Implement slide-up animation for mobile (300ms ease-out)
  - [ ] 6.2 Implement fade-in animation for desktop (150ms ease-out)
  - [ ] 6.3 Add backdrop fade-in animation
  - [ ] 6.4 Implement smooth list reordering transitions (200ms)
  - [ ] 6.5 Add swipe-down gesture to dismiss mobile menu
  
- [ ] 7.0 Testing and cleanup
  - [ ] 7.1 Test long-press on mobile devices/emulator
  - [ ] 7.2 Test right-click on desktop
  - [ ] 7.3 Verify all menu actions work correctly
  - [ ] 7.4 Test keyboard navigation (Escape to close)
  - [ ] 7.5 Run rubocop -A to fix any style issues
  - [ ] 7.6 Write controller tests for new/modified endpoints if needed
  - [ ] 7.7 Manual cross-browser testing

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