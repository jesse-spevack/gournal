# Habit Tracking Setup - Product Requirements Document

## NOTE
Implementation of this doc is mostly complete. The major outstanding feature is: [**3. Public Sharing System**](#3-public-sharing-system).

## Executive Summary
This PRD outlines the implementation of a comprehensive habit management system for the Gournal application. The system will enable users to create, edit, reorder, and manage their habits through a settings interface while maintaining the existing aesthetic bullet journal design. Additionally, it introduces public sharing capabilities through custom URLs, allowing users to share their habit tracking progress with others.

## Background
The current Gournal application has a functional habit tracking interface that displays habits in a monthly grid format with aesthetic checkbox variations. However, users cannot currently:
- Create or modify habits through the UI
- Carry habits forward to new months
- Share their progress publicly
- Access proper user authentication and settings

This feature set addresses these limitations while preserving the unique visual design that makes Gournal distinctive.

## Goals and Objectives
1. **Enable self-service habit management** - Users should be able to manage their habits without database access
2. **Streamline month-to-month tracking** - Allow users to easily set up future months with copy or fresh start options
3. **Support social accountability** - Allow users to share their progress via custom public URLs
4. **Maintain aesthetic integrity** - All new features must align with the bullet journal aesthetic
5. **Optimize for mobile** - Primary device (Pixel 8 Pro) experience must be seamless

## User Stories

### As a logged-in user, I want to:
- Add new habits through a settings interface
- Edit the names of my existing habits
- Reorder habits to match my priorities
- Soft-delete habits while preserving historical data
- Set up next month's habits with option to copy or start fresh
- Choose a custom URL slug for my public profile
- Control whether my habits and reflections are publicly visible

### As a non-authenticated visitor, I want to:
- View someone's public habit tracker via their custom URL
- See their current month's progress (read-only)
- Create my own account directly from the public view

## Detailed Requirements

### 1. Habit Management Interface

#### 1.1 Settings Access
- **Location**: Top-right corner of the habit tracker page
- **Design**: Hand-drawn bullet journal aesthetic button
- **Behavior**: Opens user settings page when clicked
- **Visibility**: Only shown to authenticated users

#### 1.2 Settings Page Structure
- **URL**: `/settings`
- **Authentication**: Required
- **Sections**:
  - Habit Management (includes "Set up next month" button)
  - Privacy Settings
  - Profile Settings

#### 1.3 Habit Management Features
- **Add Habit**:
  - Simple text input for habit name
  - Position automatically assigned (end of list)
  - Creates habit for current month/year
  - Generates HabitEntry records for all days in month
  
- **Edit Habit**:
  - Inline editing of habit names
  - Changes apply immediately
  - Historical entries maintain connection
  
- **Reorder Habits**:
  - Drag-and-drop interface (must use Stimulus)
  - Updates position field in database
  
- **Delete Habit**:
  - Soft delete (sets `active: false`)
  - Habit disappears from current view
  - Historical data preserved for analytics

### 2. Monthly Habit Setup

#### 2.1 Month Setup Interface
- **Access**: "Set up next month" button in Settings page
- **Location**: Prominent placement in Habit Management section
- **Behavior**: Opens month setup workflow for the upcoming month

#### 2.2 Setup Options
When user clicks "Set up next month", they see two options:

1. **"Copy from current month"** (one-click):
   - Copies all active habits from current month
   - Maintains names and positions
   - Creates new Habit records for target month
   - Generates HabitEntry records for all days
   - Returns user to settings with success message

2. **"Start fresh"**:
   - Creates empty month ready for new habits
   - User manually adds habits one by one
   - Useful for major routine changes or new beginnings

#### 2.3 Setup Constraints
- Can only set up future months (not past)
- Can only set up one month at a time
- If month already has habits, show option to add more or clear and restart

#### 2.4 HabitCopyService
```ruby
class HabitCopyService
  def self.call(user:, from_month:, from_year:, to_month:, to_year:)
    # Implementation details in code
  end
end
```

### 3. Public Sharing System

#### 3.1 User Slug Management
- **Field**: `users.slug` (string, unique)
- **Validation**: 
  - URL-safe characters only (a-z, 0-9, hyphen)
  - Minimum 3 characters
  - Maximum 30 characters
  - Case-insensitive uniqueness
- **Setting Location**: Profile Settings section

#### 3.2 Privacy Controls
- **Fields**:
  - `users.habits_public` (boolean, default: false)
  - `users.reflections_public` (boolean, default: false)
- **UI**: Toggle switches in Privacy Settings section in the style of the app's checkboxes
- **Behavior**: Controls visibility on public profile

#### 3.3 Public Profile
- **URL Pattern**: `/{slug}` (e.g., `/jesse`)
- **Authentication**: Not required
- **Content**:
  - Current month's habit tracker (if habits_public = true)
  - Daily reflections (if reflections_public = true)
  - User's chosen display name
- **Restrictions**:
  - Read-only view
  - No checkbox interactions
  - No reflection editing
- **CTA**: "Create Account" button in place of Settings button - should be an icon in the style of the gournal app

### 4. Mobile Optimization

#### 4.1 Target Device
- **Primary**: Pixel 8 Pro
- **Viewport**: 412x915px
- **DPI**: Consider high-density display

#### 4.2 Touch Optimizations
- **Checkbox Size**: Maintain current 24px with adequate tap targets
- **Drag Handles**: Minimum 44px touch target for reordering
- **Button Spacing**: Adequate padding around interactive elements
- **Scroll**: Smooth scrolling with momentum

#### 4.3 Responsive Considerations
- **Grid Layout**: Horizontal scroll for many habits
- **Settings Page**: Single column layout
- **Form Inputs**: Full-width on mobile
- **Modals**: Full-screen on mobile devices

### 5. Authentication Enhancement

#### 5.1 Access Control
- **Public Routes**:
  - `/{slug}` - Public profiles
  - `/login` - Authentication
  - `/signup` - Registration
  
- **Protected Routes**:
  - `/settings` - User settings
  - `/habit_entries` - Habit tracker (when logged in)
  - All modification endpoints

#### 5.2 User Context
- Remove hardcoded `ENV["FIRST_USER"]`
- Use proper session-based authentication
- Current user context available throughout app

## Database Schema Updates

```sql
-- Add to users table
ALTER TABLE users ADD COLUMN slug VARCHAR(30);
ALTER TABLE users ADD COLUMN habits_public BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN reflections_public BOOLEAN DEFAULT FALSE;
CREATE UNIQUE INDEX index_users_on_slug ON users(LOWER(slug));

-- Note: habits table already has 'active' field for soft-delete
```

## Technical Implementation Plan

### Phase 1: Core Infrastructure (Week 1)
1. Create database migrations
2. Update User model with validations
3. Create Settings controller
4. Add routes for settings and public profiles
5. Implement authentication checks

### Phase 2: Habit Management (Week 1-2)
1. Build settings page layout
2. Implement habit CRUD operations
3. Add AJAX for inline editing (must be stimulus)
4. Create drag-and-drop reordering
5. Implement soft delete functionality

### Phase 3: Month Setup System (Week 2)
1. Create HabitCopyService
2. Add "Set up next month" button to settings
3. Implement copy/start fresh workflow
4. Add validation for future months only
5. Add tests for edge cases

### Phase 4: Public Sharing (Week 2-3)
1. Create PublicProfiles controller
2. Build read-only habit view
3. Add slug selection to settings
4. Implement privacy toggles
5. Add "Create Account" CTA

### Phase 5: UI Polish (Week 3)
1. Design hand-drawn settings button
2. Create consistent form styling
3. Add loading states and animations
4. Implement error handling
5. Mobile testing and optimization

### Phase 6: Testing & Launch (Week 3-4)
1. Unit tests for services
2. Integration tests for controllers
3. Manual testing on Pixel 8 Pro
4. Performance optimization
5. Documentation updates

## Success Metrics
- **Adoption**: 80% of users create habits through UI within first month
- **Retention**: 60% of users use "Set up next month" feature
- **Sharing**: 20% of users enable public sharing
- **Mobile**: 90% of interactions happen on mobile devices
- **Performance**: Settings page loads in <500ms

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Slug collisions | Medium | First-come-first-served with suggestions for alternatives |
| Performance with many habits | Low | Pagination or virtualization if >20 habits |
| Privacy concerns | High | Clear privacy controls, default to private |
| Mobile drag-and-drop issues | Medium | Provide alternative reordering method |
| Habit explosion over months | Low | Limit active habits or archive old ones |

## Future Considerations
- Habit templates/presets for common goals
- Habit statistics and analytics dashboard
- Export functionality (PDF, CSV)
- API for third-party integrations
- Collaborative habits with accountability partners
- Habit recommendations based on user patterns

## Acceptance Criteria
- [ ] Users can create, edit, reorder, and delete habits through UI
- [ ] "Set up next month" allows copy from current or start fresh
- [ ] Month setup only available for future months
- [ ] Public profiles accessible via custom slugs
- [ ] Privacy settings control visibility
- [ ] Mobile experience optimized for Pixel 8 Pro
- [ ] All features maintain bullet journal aesthetic
- [ ] No regression in existing functionality
- [ ] Tests provide adequate coverage

## Design Mockups
*To be created - showing:*
1. Settings button placement
2. Settings page layout
3. Habit management interface
4. Public profile view
5. Mobile responsive layouts

## Questions for Stakeholders
All questions have been answered during the requirements gathering phase.

## Appendix

### A. Existing Code Structure
- **Models**: User, Habit, HabitEntry, DailyReflection
- **Controllers**: HabitEntriesController
- **Services**: HabitTrackerDataBuilder, HabitCopyService (to be created)
- **Views**: Habit tracker grid with aesthetic checkboxes

### B. Design System
- **Aesthetic**: Hand-drawn bullet journal
- **Checkboxes**: 10 box styles, 10 X styles, 10 blot styles
- **Colors**: Ink and paper themed
- **Typography**: Consistent with journal aesthetic

### C. Technical Stack
- Ruby on Rails 8
- Propshaft + Dart Sass
- Stimulus.js for interactivity
- PostgreSQL database
- Mobile-first responsive design

---

*Document Version: 1.0*  
*Date: September 2, 2025*  
*Author: Product Team*  
*Status: Approved for Implementation*