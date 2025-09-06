# Habit Tracker Context Menu UI Revision
## Product Requirements Document

### Overview
Replace the current drag-and-drop reordering system with a context menu approach to improve mobile UX while maintaining the minimalist bullet journal aesthetic. Unify interaction patterns across mobile and desktop platforms.

---

## Current State vs. Proposed State

### Current Issues
- Drag handles (≡) create visual clutter
- Drag-and-drop conflicts with mobile scrolling
- Accidental reordering during normal use
- Small touch targets for drag handles

### Proposed Solution
- Remove all drag handles for cleaner interface
- Context menu for habit management actions
- Platform-appropriate triggers (long-press mobile, right-click desktop)
- Maintain existing tap-to-edit functionality

---

## Interaction Model

### Mobile Web
**Primary Actions:**
- **Tap habit name** → Edit habit name inline
- **Tap outside** → Save edit and exit edit mode
- **Long-press habit** → Open context menu

**Context Menu Access:**
- Long-press on any habit item
- Menu slides up from bottom of screen
- Semi-transparent backdrop appears

**Context Menu Dismissal:**
- Tap backdrop/outside menu
- Swipe down gesture on menu
- Tap "Cancel" button in menu

### Desktop Web
**Primary Actions:**
- **Click habit name** → Edit habit name inline
- **Click outside** → Save edit and exit edit mode
- **Right-click habit** → Open context menu

**Context Menu Access:**
- Right-click on any habit item
- Menu appears near cursor position
- Subtle backdrop for focus

**Context Menu Dismissal:**
- Click backdrop/outside menu
- Escape key
- Click "Cancel" button in menu

---

## Context Menu Actions

### Available Actions
1. **Edit Name** - Enter inline edit mode
2. **Move Up** - Move habit one position up in list
3. **Move Down** - Move habit one position down in list
4. **Delete Habit** - Remove habit permanently
5. **Cancel** - Close menu without action

### Action Behavior
- **Edit Name**: Closes menu, enters inline edit mode
- **Move Up/Down**: Immediate action, menu closes, list updates
- **Delete**: Immediate action with subtle confirmation
- **Cancel**: Menu closes, no changes

---

## ASCII Layout

### Closed State (Normal List View)
```
┌─────────────────────────────────┐
│ Settings                    < │
├─────────────────────────────────┤
│                                 │
│ Manage habits                   │
│                                 │
│ • Run                           │
│ • Pushups                       │
│ • Stretch                       │
│ • Nutrition                     │
│ • Bed@10                        │
│                                 │
│ • Add new habit                 │
│                                 │
└─────────────────────────────────┘
```

### Open State (Context Menu Active)
```
┌─────────────────────────────────┐
│ Settings                    < │
├─────────────────────────────────┤
│░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│ ← Backdrop
│░• Run                       ░░░│
│░• Pushups   [SELECTED]      ░░░│
│░• Stretch                   ░░░│
│░• Nutrition                 ░░░│
│░• Bed@10                    ░░░│
│░                            ░░░│
│░• Add new habit             ░░░│
│░                            ░░░│
│░┌─────────────────────────────┐░│
│░│ Edit Name                   │░│
│░│ Move Up                     │░│
│░│ Move Down                   │░│
│░│ Delete Habit                │░│
│░│ Cancel                      │░│
│░└─────────────────────────────┘░│
└─────────────────────────────────┘
```

---

## Style Guidelines

### Design System Integration
- Reference existing design tokens for colors, typography, spacing
- Maintain current font family and weight hierarchy
- Use established color palette (notebook aesthetic)

### Context Menu Styling
**Visual Design:**
- Clean, minimal appearance matching main interface
- Text-only actions (no icons) for simplicity
- Consistent typography with habit list
- Subtle borders and shadows for depth

**Mobile Menu:**
- Slides up from bottom with smooth animation
- Rounded top corners matching design system
- Full-width on small screens, max-width on larger screens
- Touch-friendly 44px minimum touch targets

**Desktop Menu:**
- Positioned near click point
- Compact sizing appropriate for mouse precision
- Subtle drop shadow for layering
- Hover states for menu items

### Animation & Transitions
- **Mobile slide-up**: 300ms ease-out
- **Desktop fade-in**: 150ms ease-out
- **Backdrop**: Fade in with menu animation
- **List updates**: Subtle 200ms position transitions for reordering

---

## Desktop Adaptations

### Enhanced Desktop Features
**Keyboard Support:**
- Arrow keys to navigate menu items
- Enter to select action
- Escape to close menu
- Tab navigation support

**Mouse Interactions:**
- Hover states on menu items
- Right-click context menu standard behavior
- Precise click targets (smaller than mobile)

**Layout Considerations:**
- Context menu appears near cursor
- Respect screen boundaries (flip menu if needed)
- Maintain visual hierarchy with subtle layering

---

## Technical Considerations

### Responsive Behavior
- Use `@media (hover: hover) and (pointer: fine)` for desktop-specific styles
- Feature detection for touch vs. mouse interactions
- Graceful fallback for devices with both touch and mouse

### Accessibility
- Proper ARIA labels for context menu
- Keyboard navigation support
- Screen reader announcements for actions
- Focus management when menu opens/closes

### Performance
- Lazy-load context menu component
- Minimal DOM manipulation for smooth animations
- Efficient event handling for backdrop clicks

---

## Success Metrics

### User Experience Goals
- Reduced accidental habit reordering
- Faster habit management task completion
- Improved mobile usability scores
- Maintained aesthetic satisfaction ratings

### Technical Goals
- Single codebase for menu functionality
- Reduced interface complexity
- Improved touch target accessibility
- Consistent cross-platform behavior