# Habit Tracker PRD
*Japanese Aesthetic Digital Bullet Journal*

## Product Overview

### Vision
Create a digital habit tracking application that captures the tactile, aesthetic experience of a bullet journal while eliminating the friction of pen and paper. The app prioritizes calm, mindful interactions with beautiful Japanese paper aesthetics over complex features or gamification.

### Problem Statement
Bullet journal enthusiasts appreciate the aesthetic and mindful nature of analog tracking but are frustrated by the physical limitations of pen and paper (erasability, portability, durability). Existing digital habit trackers are either too complex or lack the aesthetic satisfaction of physical journaling.

### Target User
People who appreciate bullet journal aesthetics but prefer digital convenience. Users who value:
- Minimalist, beautiful interfaces
- Calm, mindful daily rituals
- Aesthetic satisfaction in their tools
- Mobile-first experiences

### Success Metrics
- **3-month goal**: Working prototype in personal daily use
- **6-month goal**: Multi-user adoption with consistent daily engagement
- **Primary KPI**: Daily active usage (evening ritual completion)

## Core User Journey

### Daily Workflow
1. User opens app in the evening
2. Views current month's habit grid
3. Fills in completed habits with satisfying ink blotch interactions
4. Optionally adds single-line reflection for the day
5. Enjoys the aesthetic result and feels accomplished

### Monthly Workflow
1. At month start, user is prompted to set up habits
2. Option to copy from previous month or create new set
3. Habits can be added/removed throughout the month
4. Navigate between months with simple prev/next arrows

## Feature Requirements

### MVP Features (v1.0)

#### Core Functionality
- **Monthly habit grid view**: Japanese paper aesthetic, mobile-optimized
- **Custom habit creation**: User-defined habit names, limited by screen width
- **Checkbox interactions**: 
  - Hand-drawn checkbox borders (many variations to mimic random variations in hand writing in a bullet journal)
  - Ink blotch fills (many variations to mimic random variations in hand writing in a bullet journal) 
  - Random selection for organic feel
- **Daily reflections**: Optional single-line text, truncated with ellipsis
- **Data persistence**: Edit any previous day, no future date entry
- **Month navigation**: Simple previous/next month arrows
- **Habit management**: Add/remove habits anytime during month

#### User Interface
- **Mobile-first responsive design**
- **Japanese paper texture throughout**
- **Hand-drawn aesthetic**: Courier New typography, organic shapes
- **Cover art section**: Auto-populated month/year
- **Minimal, calm visual design**
- **One-screen month view** (entire month visible on mobile)

#### Technical Requirements
- **Rails web application**
- **Mobile-optimized responsive design**
- **Internet-required (offline support in future)**
- **SQLite database**
- **SVG-based graphics for crispness**
  - `views/shared/` - partials for reusabilty

### Future Features (Post-MVP)

#### Enhanced Interactions
- **Drawing/writing effects** for reflections
- **Sound effects** (pen scratching, paper rustling)
- **AI-generated cover artwork**
- **Custom ink color schemes**

#### Advanced Views
- **Historical trend views**
- **Weekly summaries**
- **Zoomed-out all-months preview**
- **Multi-device sync**
- **Offline functionality**

#### User Experience
- **Onboarding tutorial**
- **Sample data for new users**
- **Habit templates/presets**

## Technical Architecture

### Data Model
```
User
- has_many :habits
- has_many :habit_entries (through habits)

Habit  
- belongs_to :user
- has_many :habit_entries
- name (string)
- month (integer)
- year (integer)
- position (integer)

HabitEntry
- belongs_to :habit
- day (integer, 1-31)
- completed (boolean)
- created_at/updated_at

DailyReflection
- belongs_to :user
- date (date)
- content (text)
```

### Key Technical Decisions
- **Rails 8** with Turbo and Stimulus for interactions
- **Mobile-first responsive CSS**
- **SVG graphics** for checkbox variations
- **Local storage fallback** for offline (future)
- **Simple authentication** (future)

## User Stories

### MVP User Stories

**As a habit tracker user, I want to:**
- Set up my habits for the month so I can track what matters to me
- See all my habits and days in one mobile screen view
- Check off completed habits with satisfying visual feedback
- Add optional daily reflections to capture my thoughts
- Edit previous days if I forgot to log something
- Navigate between months to see my progress over time
- Copy habits from previous months to save setup time

### Future User Stories

**As a regular user, I want to:**
- See trends in my habit completion over time
- Customize my ink colors to match my mood
- Use the app offline when I don't have internet
- Have AI generate beautiful monthly cover art
- Export or share my monthly views

## Design Requirements
- Follow the design-system.html
- design-system.html is the source of truth

### Visual Principles
- **Calm and mindful**: No aggressive colors, notifications, or gamification
- **Japanese aesthetic**: Washi paper textures, organic imperfections
- **Tactile feedback**: Hand-drawn elements, ink flow simulation
- **Mobile-optimized**: Thumb-friendly interactions, readable text
- **Minimalist**: Clean layout, essential elements only

### Interaction Design
- **Organic randomness**: Each checkbox uses random variations
- **Ink blotch satisfaction**: Filling feels like real pen marks
- **Smooth navigation**: Fluid month transitions
- **Forgiving UX**: Easy to edit, no harsh validation

### Typography & Colors
- **Primary font**: Courier New monospace (typewriter aesthetic)
- **Accent font**: Georgia serif (watermark only)
- **Color palette**: 
  - Ink: #1a2332 (dark blue-black)
  - Paper: #fdfbf7 to #f3ede3 (warm off-whites)
  - Opacity variations for organic feel

## Success Criteria & Metrics

### 3-Month Success (Personal Use)
- **Daily usage**: Personal habit tracking every evening
- **Technical stability**: No crashes, smooth performance
- **Aesthetic satisfaction**: Enjoy using it more than alternatives
- **Feature completeness**: All MVP features working

### 6-Month Success (Multi-User)
- **User acquisition**: 10+ active users through word-of-mouth
- **Engagement**: Average 5+ days per week usage
- **Retention**: 50%+ users active after first month
- **Aesthetic appeal**: Positive feedback on design/feel

### Key Performance Indicators
- **Daily Active Users (DAU)**
- **Habit completion rate** (secondary)
- **Reflection usage rate** (secondary)
- **Month-over-month retention**
- **Time spent in app** (session duration)

## Timeline & Roadmap

### Phase 1: MVP Development (Months 1-3)
- **Phase 1**: Core Rails app, data model, basic UI
- **Phase 2**: Checkbox interactions, Japanese aesthetic polish
- **Phase 3**: Mobile optimization, personal testing, bug fixes

### Phase 2: Refinement (Months 4-6)
- **Phase 4**: Performance optimization, edge case handling
- **Phase 5**: User testing with 2-3 friends, feedback iteration
- **Phase 6**: Multi-user deployment, word-of-mouth launch

### Phase 3: Enhancement (Months 7+)
- Custom ink colors and themes
- Historical views and analytics
- Offline functionality
- AI-generated artwork
- Sound effects and enhanced interactions

## Open Questions & Risks

### Technical Risks
- **Mobile performance**: SVG rendering on older devices
- **Responsive design**: Fitting variable habits on small screens
- **Data migration**: Handling schema changes as features evolve

### Product Risks
- **Aesthetic appeal**: Will digital feel satisfying enough?
- **Habit limits**: Will screen-width constraints frustrate users?
- **Engagement**: Will minimal approach maintain daily usage?

### Validation Needed
- **Interaction feedback**: Do ink blotches feel satisfying?
- **Mobile usability**: Can users easily tap checkboxes on small screens?
- **Aesthetic resonance**: Does Japanese paper theme appeal to target users?

---

*This PRD will evolve based on user feedback and development learnings. The focus remains on creating a beautiful, calm, and satisfying digital habit tracking experience.*