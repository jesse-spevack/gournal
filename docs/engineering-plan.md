# Habit Tracker Engineering Plan

## Implementation Status

### Overall Progress: 🟡 In Progress (25%)

| Phase | Status | Progress | Notes |
|-------|--------|----------|-------|
| Phase 0: Environment & CI/CD | 🟢 Complete | 100% | Ruby 3.4.5, Rails 8.0.2.1, CI/CD configured, Style guide complete |
| Phase 1: Foundation & Models | 🔴 Not Started | 0% | Rails app initialized, models pending |
| Phase 2: Core Features | 🔴 Not Started | 0% | - |
| Phase 3: Interactive Features | 🔴 Not Started | 0% | - |
| Phase 4: Visual Design | 🟡 In Progress | 50% | Checkbox component system complete, style guide functional |
| Phase 5: Deployment | 🔴 Not Started | 0% | - |

**Legend**: 🔴 Not Started | 🟡 In Progress | 🟢 Complete | ⚠️ Blocked

### Quick Progress Checklist

#### Phase 0: Environment & CI/CD ✅ COMPLETE
- [🟢] Ruby 3.4.5 installed
- [🟢] Rails 8.0.2.1 app initialized
- [🟢] GitHub repository created
- [🟢] Style guide scaffolded and fully implemented (30+ checkbox components)
- [🟢] CI pipeline configured (.github/workflows/ci.yml)
- [🟢] CD pipeline configured (config/deploy.yml for Kamal)
- [🟢] Development tooling setup (Solid Cache/Queue gems installed)

#### Phase 1: Foundation & Models
- [ ] Database schema created
- [ ] User model implemented
- [ ] Habit model implemented
- [ ] HabitEntry model implemented
- [ ] DailyReflection model implemented
- [ ] Model validations complete
- [ ] Model tests passing
- [ ] Seed data generator created

#### Phase 2: Core Features
- [ ] SVG checkbox renderer built
- [ ] Habits controller created
- [ ] Monthly grid view working
- [ ] Add/remove habits functional
- [ ] Checkbox toggling works
- [ ] Controller tests passing

#### Phase 3: Interactive Features
- [ ] Stimulus controllers created
- [ ] Turbo frames implemented
- [ ] Daily reflections working
- [ ] Month navigation smooth
- [ ] Auto-save functional
- [ ] System tests passing

#### Phase 4: Visual Design (50% Complete)
- [🟢] Hand-drawn checkboxes (30+ variations complete)
- [🟢] Mix-and-match checkbox system (200+ combinations)
- [🟢] Component library in app/views/style_guide/
- [🟢] Additional components in app/views/checkboxes/
- [ ] Japanese paper background styling
- [ ] Mobile layout optimized
- [ ] Touch targets sized
- [ ] Cover art designed
- [ ] Visual tests passing

#### Phase 5: Deployment
- [ ] Performance optimized
- [ ] Kamal configured
- [ ] HTTP auth setup
- [ ] Production database ready
- [ ] Deployment successful
- [ ] Performance metrics met

## Project Overview
Building a Rails 8.0.2 digital habit tracker with Japanese bullet journal aesthetics, optimized for mobile devices (412px viewport), using Rails defaults with Turbo/Stimulus for interactions. Development follows Test-Driven Development (TDD) methodology throughout.

## Technical Stack
- **Rails**: 8.0.2
- **Stimulus**: 3.2.2  
- **Turbo**: 8.0.13
- **Database**: SQLite (development and production)
- **Testing**: Minitest with fixtures (unit and integration tests only, no system tests)
- **Deployment**: Kamal
- **CSS**: Dartsass-rails with SCSS
- **Caching**: Solid Cache
- **Jobs**: Solid Queue

## Core Principles
- TDD: Write tests first for all features
- Rails defaults: Minimize dependencies
- Mobile-first: Optimize for 412px viewport (Pixel 8 Pro)
- Beautiful bullet journal aesthetic: Mimics handwriting variance
- Data persistence: Retain all user data indefinitely

## Phase 0: Development Environment & CI/CD (Week 0 - Setup)

### Status: 🟢 Complete

| Task | Status | Notes |
|------|--------|-------|
| 0.1 Development Environment Setup | 🟢 | Ruby 3.4.5, Rails 8.0.2.1, Git configured |
| 0.2 CI/CD Pipeline Configuration | 🟡 | Basic setup done, needs fine-tuning |
| 0.3 Development Tooling | 🔴 | Seed data generator pending |
| 0.4 Style Guide & Component Library | 🟢 | **Complete** - 30+ checkbox variations, style guide controller |

### 0.1 Development Environment Setup
**TDD Approach**: Write tests for development tooling and scripts
```ruby
# test/setup/environment_test.rb
test "required Ruby version is installed" do
  assert RUBY_VERSION.start_with?("3.4")
end

test "required Node version is available" do
  node_version = `node --version`.strip
  assert node_version.start_with?("v20")
end
```

**Implementation**:
- Ruby 3.4.5 with asdf setup
- Node.js 20.x for JavaScript tooling
- PostgreSQL 15+ for future production migration
- Redis for ActionCable (future features)
- ImageMagick for potential image processing
- Git hooks for pre-commit linting

### 0.2 CI/CD Pipeline Configuration
**GitHub Actions Workflow**:
```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.4
          bundler-cache: true
      - name: Setup database
        run: |
          bin/rails db:create
          bin/rails db:schema:load
      - name: Run tests
        run: |
          bundle exec rails test
          bundle exec rails test:controllers
      - name: Run linters
        run: |
          bundle exec rubocop
          npm run lint
```

**CD Pipeline for Kamal**:
```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Kamal
        run: gem install kamal
      - name: Deploy
        run: kamal deploy
        env:
          KAMAL_REGISTRY_PASSWORD: ${{ secrets.REGISTRY_PASSWORD }}
          RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}
```

### 0.3 Development Tooling
**Scripts and Automation**:
```ruby
# lib/tasks/dev.rake
namespace :dev do
  desc "Generate comprehensive seed data"
  task seed: :environment do
    puts "Creating demo user with varied habit patterns..."
    SeedGenerator.new.generate_realistic_data
  end

  desc "Reset database with fresh seed data"
  task reset: [:environment, "db:reset", :seed] do
    puts "Database reset with seed data complete"
  end
end
```

**Simplified Seed Data**:
```ruby
# db/seeds.rb
# Simple seed data for development
if Rails.env.development?
  user = User.find_or_create_by!(email_address: "demo@example.com") do |u|
    u.password = "password"
  end
  
  # Current month habits
  5.times do |i|
    habit = Habit.find_or_create_by!(
      user: user,
      name: ["Exercise", "Reading", "Meditation", "Journaling", "Water"][i],
      month: Date.current.month,
      year: Date.current.year,
      position: i + 1
    )
    user = User.create!(email: "demo@example.com")
    
    # Generate 3 months of habit data with realistic patterns
    3.times do |month_offset|
      date = month_offset.months.ago
      
      # Create habits with different completion patterns
      habits = [
        { name: "Exercise", completion_rate: 0.8 },
        { name: "Reading", completion_rate: 0.6 },
        { name: "Meditation", completion_rate: 0.9 },
        { name: "Journaling", completion_rate: 0.7 },
        { name: "Water intake", completion_rate: 0.85 }
      ]
      
      habits.each_with_index do |habit_data, position|
        habit = Habit.create!(
          user: user,
          name: habit_data[:name],
          month: date.month,
          year: date.year,
          position: position + 1
        )
        
        # Generate entries with realistic patterns
        days_in_month = Date.new(date.year, date.month, -1).day
        days_in_month.times do |day|
          entry = HabitEntry.create!(
            habit: habit,
            day: day + 1,
            checkbox_style: HabitEntry.checkbox_styles.keys.sample,
            check_style: HabitEntry.check_styles.keys.sample
          )
          
          # Complete based on completion rate with some randomness
          if rand < habit_data[:completion_rate]
            entry.update!(completed: true) if day < Date.current.day
          end
        end
  end
end
```

### 0.4 Style Guide & Component Library ✅ **COMPLETE**

**Implementation Achievement**: Created comprehensive checkbox component system with full mix-and-match capabilities.

**Components Created**:
- 30+ individual checkbox partials in `app/views/style_guide/` and `app/views/checkboxes/`
- 10 box variations, 10 X-mark variations, 10+ blot variations
- Mix-and-match system supporting 200+ combinations
- StyleGuideController at `/style_guide` route
- Test coverage in `test/controllers/style_guide_controller_test.rb`

**Key Files**:
- Style guide components in `app/views/style_guide/`
- Checkbox library in `app/views/checkboxes/`
- Controller: `app/controllers/style_guide_controller.rb`

**Usage Examples**:
```erb
<%= render 'style_guide/checkbox_mixed', box: 3, fill: 'blot_7' %>
<%= render 'style_guide/checkbox_mixed', box: 5, fill: 'x_2' %>
<%= render 'style_guide/checkbox_mixed', box: 8, fill: nil %>
```

**Technical Implementation**:
- Data structures for all box paths and fill patterns
- Parameterized component architecture
- Consistent SVG viewBox (24x24) across all variations
- Hand-drawn aesthetic with controlled randomness
- Japanese bullet journal design system compliance

**Living Style Guide**:
```ruby
# test/controllers/style_guide_controller_test.rb  
test "style guide index accessible in development" do
  get style_guide_path
  assert_response :success
end
```

**Current Implementation**:
- StyleGuideController exists and is functional
- Comprehensive checkbox component library complete
- SCSS-based styling with dartsass-rails
- Solid Cache and Solid Queue gems installed and ready

## Phase 1: Foundation & Core Models (Week 1)

### Status: 🔴 Not Started

| Task | Status | Notes |
|------|--------|-------|
| 1.1 Rails Application Setup | 🔴 | - |
| 1.2 Database Schema & Models | 🔴 | - |
| 1.3 Model Validations & Business Logic | 🔴 | - |

### 1.1 Rails Application Setup
**TDD Approach**: Write smoke tests for application configuration
```ruby
# test/application_system_test_case.rb
# Verify Rails app boots and responds
```

**Implementation**:
- Initialize Rails 8.0.2 app: `rails new habit_tracker --database=sqlite3 --css=dartsass`
- Configure `config/application.rb` for Rails defaults
- Set up `bin/dev` for development workflow
- Initialize git repository
- Create initial smoke test for root path

### 1.2 Database Schema & Models
**TDD Approach**: Write model tests first for each entity

```ruby
# test/models/habit_test.rb
test "habit requires name, month, year, position" do
  habit = Habit.new
  assert_not habit.valid?
  assert_includes habit.errors[:name], "can't be blank"
end

test "habit belongs to user and has many entries" do
  habit = habits(:exercise)
  assert_equal users(:alice), habit.user
  assert_equal 31, habit.habit_entries.count
end
```

**Schema Design**:
```ruby
# users table (generated by Rails 8 authentication)
t.string :email_address, null: false
t.string :password_digest, null: false
t.timestamps
add_index :users, :email_address, unique: true

# habits table  
t.references :user, null: false, foreign_key: true, index: true
t.string :name, null: false
t.integer :month, null: false
t.integer :year, null: false
t.integer :position, null: false
t.boolean :active, default: true
t.timestamps
add_index :habits, [:user_id, :year, :month, :position], unique: true

# habit_entries table
t.references :habit, null: false, foreign_key: true, index: true
t.integer :day, null: false  # 1-31
t.boolean :completed, default: false
t.integer :checkbox_style, default: 0, null: false  # enum
t.integer :check_style, default: 0, null: false     # enum
t.timestamps
add_index :habit_entries, [:habit_id, :day], unique: true

# daily_reflections table
t.references :user, null: false, foreign_key: true, index: true
t.date :date, null: false
t.text :content, limit: 255
t.timestamps
add_index :daily_reflections, [:user_id, :date], unique: true
```

### 1.3 Model Validations & Business Logic
**TDD Tests to Write**:
```ruby
# test/models/habit_entry_test.rb
test "cannot check off future dates" do
  entry = habit_entries(:tomorrow)
  entry.completed = true
  assert_not entry.valid?
  assert_includes entry.errors[:day], "cannot be in the future"
end

test "assigns random checkbox styles on creation" do
  entry = HabitEntry.create!(habit: habits(:exercise), day: 15)
  assert_includes HabitEntry.checkbox_styles.keys, entry.checkbox_style
  assert_includes HabitEntry.check_styles.keys, entry.check_style
end

test "checkbox styles persist and don't change" do
  entry = habit_entries(:day_one)
  original_style = entry.checkbox_style
  entry.reload
  assert_equal original_style, entry.checkbox_style
end
```

**Model Implementation**:
```ruby
class HabitEntry < ApplicationRecord
  enum :checkbox_style, { box_style_1: 0, box_style_2: 1, box_style_3: 2, box_style_4: 3, box_style_5: 4 }
  enum :check_style, { x_style_1: 0, x_style_2: 1, x_style_3: 2, x_style_4: 3, x_style_5: 4 }
  
  validates :day, inclusion: { in: 1..31 }
  validate :no_future_dates
  
  before_create :assign_random_styles
  
  private
  
  def assign_random_styles
    self.checkbox_style = self.class.checkbox_styles.keys.sample
    self.check_style = self.class.check_styles.keys.sample
  end
end

class Habit < ApplicationRecord
  validates :month, inclusion: { in: 1..12 }
  validates :name, presence: true
  
  scope :current_month, -> { where(year: Date.current.year, month: Date.current.month) }
  
  def self.copy_from_previous_month(user, year, month)
    # Implementation
  end
end
```

## Phase 2: Core Features & Controllers (Week 2)

### Status: 🔴 Not Started

| Task | Status | Notes |
|------|--------|-------|
| 2.1 SVG Checkbox Rendering System | 🔴 | - |
| 2.2 Habits Controller & Monthly Grid | 🔴 | - |
| 2.3 Habit Management Features | 🔴 | - |

### 2.1 SVG Checkbox Rendering System
**TDD Tests**:
```ruby
# test/models/checkbox_renderer_test.rb
test "renders correct SVG for checkbox style 1" do
  svg = CheckboxRenderer.new(style: 1, checked: false).render
  assert_match /M 3.3,3.8 C 3.1,3.3/, svg
  assert_no_match /x-mark/, svg
end

test "includes X mark when checked" do
  svg = CheckboxRenderer.new(style: 1, check_style: 3, checked: true).render
  assert_match /x-mark show/, svg
  assert_match /x-path-1/, svg
end
```

**Implementation**:
- `app/models/concerns/checkbox_renderable.rb` - generates SVG markup
- Store 5 box path variations from design system
- Store 5 X-mark path variations from design system
- Helper method: `render_habit_checkbox(entry)`

### 2.2 Habits Controller & Monthly Grid
**TDD Tests**:
```ruby
# test/controllers/habits_controller_test.rb
test "index shows current month by default" do
  get root_path
  assert_response :success
  assert_select "h1", Date.current.strftime("%B %Y")
end

test "displays all habits for current month" do
  get root_path
  assert_select ".habit-column", count: 3  # fixture has 3 habits
  assert_select ".day-row", count: 31
end

test "prevents checking future dates" do
  tomorrow = Date.current + 1.day
  patch habit_entry_path(@habit, day: tomorrow.day), 
        params: { completed: true }
  assert_response :unprocessable_entity
end
```

**Controller Actions**:
**HabitsController**:
- `index` - display current month grid
- `show` - display specific month/year  
- `new` - form for new habit
- `create` - add new habit to month
- `edit` - form to edit habit
- `update` - update habit details
- `destroy` - remove habit from month

**HabitEntriesController**:
- `update` - toggle checkbox state (RESTful)

### 2.3 Habit Management Features
**TDD Tests**:
```ruby
# test/controllers/habits_controller_test.rb
test "can create new habit" do
  post habits_path, params: { habit: { name: "Meditation" } }
  assert_response :redirect
  assert_equal "Meditation", Habit.last.name
end

test "can copy habits from previous month" do
  post habits_path, params: { 
    habit: { copy_from_previous: true },
    year: 2025, 
    month: 1 
  }
  assert_response :redirect
  # Verify habits were copied in controller logic
end

test "enforces habit limit" do
  10.times { create(:habit) }
  post habits_path, params: { habit: { name: "Too Many" } }
  assert_response :unprocessable_entity
end
```

**Features to Implement**:
- Add/remove habits with Turbo Frames
- Reorder habits by updating position
- Copy habits from previous month
- Enforce habit limit (3-10 based on testing)

## Phase 3: Interactive Features (Week 3)

### Status: 🔴 Not Started

| Task | Status | Notes |
|------|--------|-------|
| 3.1 Stimulus Controllers | 🔴 | - |
| 3.2 Turbo Integration | 🔴 | - |
| 3.3 Daily Reflections | 🔴 | - |

### 3.1 Stimulus Controllers
**TDD Approach**: Write controller tests for JavaScript endpoints

```ruby
# test/controllers/habit_entries_controller_test.rb  
test "updates habit entry completion status" do
  entry = habit_entries(:one)
  patch habit_entry_path(entry), params: { completed: true }
  assert_response :success
  assert entry.reload.completed?
end
```

**Stimulus Controllers**:
```javascript
// app/javascript/controllers/checkbox_controller.js
// - Toggle checkbox state
// - POST update to server
// - Handle loading states

// app/javascript/controllers/habit_controller.js
// - Add/remove habit rows
// - Handle reordering
// - Update positions

// app/javascript/controllers/reflection_controller.js
// - Auto-save on blur
// - Character limit enforcement
// - Show save indicator

// app/javascript/controllers/month_navigator_controller.js
// - Previous/next month navigation
// - Update URL without full reload
```

### 3.2 Turbo Integration
**TDD Tests**:
```ruby
# test/controllers/habits_controller_test.rb
test "month navigation returns turbo frame content" do
  get habits_path(year: 2025, month: 2), headers: { "Turbo-Frame" => "month-content" }
  assert_response :success
  assert_match /turbo-frame/, response.body
end
```

**Turbo Implementation**:
- Wrap monthly grid in `turbo_frame_tag "month-content"`
- Habit forms use Turbo Streams for updates
- Reflection updates via Turbo Stream
- Loading indicators for async operations

### 3.3 Daily Reflections
**TDD Tests**:
```ruby
# test/controllers/daily_reflections_controller_test.rb
test "can create daily reflection" do
  post daily_reflections_path, params: { 
    daily_reflection: { date: Date.current, content: "Great day!" } 
  }
  assert_response :success
  assert_equal "Great day!", DailyReflection.last.content
end

test "truncates long content in display" do
  long_text = "a" * 300
  reflection = create(:daily_reflection, content: long_text)
  # Test truncation logic in helper/model methods
end
```

**Implementation**:
- Single-line input for each day
- Auto-save on blur via Stimulus
- CSS truncation with ellipsis
- Store full text, display truncated

## Phase 4: Visual Design & Mobile Optimization (Week 4)

### Status: 🔴 Not Started

| Task | Status | Notes |
|------|--------|-------|
| 4.1 Japanese Paper Aesthetic | 🔴 | - |
| 4.2 Mobile-First Responsive Design | 🔴 | - |
| 4.3 Cover Art Section | 🔴 | - |

### 4.1 Japanese Paper Aesthetic
**TDD Approach**: Test CSS helper methods and component logic

```ruby
# test/helpers/application_helper_test.rb
test "generates correct CSS variables" do
  css_vars = japanese_paper_css_variables
  assert_includes css_vars, "--ink-primary: #1a2332"
  assert_includes css_vars, "--paper-light: #fdfbf7"
end

test "checkbox renderer includes proper classes" do
  # Test checkbox rendering logic without browser
end
```

**SCSS Implementation**:
```scss
// app/assets/stylesheets/application.scss
// Design tokens using SCSS variables
:root {
  --ink-primary: #1a2332;
  --ink-hover: #0f1821;
  --paper-light: #fdfbf7;
  --paper-mid: #f8f5ed;
  --paper-dark: #f3ede3;
  --checkbox-size: 24px;
  // ... all other design tokens
}

// Japanese paper background layers
.paper-background {
  background: radial-gradient(ellipse at top left, 
    var(--paper-light) 0%, 
    var(--paper-mid) 40%, 
    var(--paper-dark) 100%);
}

// Kozo fiber texture
.kozo-texture {
  background-image: 
    repeating-linear-gradient(87deg, 
      var(--fiber-dark) 0px,
      transparent 1px,
      transparent 2px);
}
```

### 4.2 Mobile-First Responsive Design
**Implementation Notes**:
- Test mobile layouts manually
- Verify responsive breakpoints in browser dev tools
- Use CSS Grid/Flexbox for adaptive layouts

**Mobile Optimizations**:
- Viewport meta tag: `width=device-width, initial-scale=1`
- Flexible column sizing based on habit count
- Touch-friendly tap targets (minimum 44px)
- Font sizes optimized for mobile (11px days, 12px reflections)
- No horizontal scrolling at 412px width

### 4.3 Cover Art Section
**Implementation with Tests**:
```ruby
# test/helpers/application_helper_test.rb
test "formats month year for cover art" do
  result = cover_art_month_year(Date.new(2025, 8, 15))
  assert_equal "August 2025", result
end
```

**Cover Design**:
- Centered month/year display
- Courier New typography
- Decorative Japanese elements
- Consistent padding from design system

## Phase 5: Deployment & Performance (Week 5)

### Status: 🔴 Not Started

| Task | Status | Notes |
|------|--------|-------|
| 5.1 Performance Optimization | 🔴 | - |
| 5.2 Kamal Deployment Configuration | 🔴 | - |

### 5.1 Performance Optimization
**Performance Testing**:
```ruby
# Performance testing done manually in development
# Use browser dev tools to measure:
# - Initial page load time < 2 seconds
# - Checkbox interaction < 100ms response
# - No layout shifts on mobile viewport
```

**Optimizations**:
- Optimize SVG paths (minimize coordinates)
- Enable Solid Cache for fragment caching
- Use Solid Queue for background jobs
- Compress assets with Rails defaults
- Lazy load non-critical styles
- Minimize Stimulus controller size

**Solid Cache Configuration**:
```ruby
# config/environments/production.rb
config.cache_store = :solid_cache_store

# config/solid_cache.yml
production:
  database: cache
  store_options:
    max_size: 256.megabytes
    max_age: 1.week
```

**Solid Queue Configuration**:
```ruby
# config/environments/production.rb
config.active_job.queue_adapter = :solid_queue

# config/solid_queue.yml
production:
  workers:
    - queues: [default, mailers]
      threads: 3
      polling_interval: 1
```

### 5.2 Kamal Deployment Configuration
**Configuration Files**:
```yaml
# config/deploy.yml
service: habit-tracker
image: habit-tracker

servers:
  web:
    - your-server.com

registry:
  username: your-username
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  clear:
    RAILS_LOG_TO_STDOUT: true
  secret:
    - RAILS_MASTER_KEY
    - HTTP_AUTH_USERNAME
    - HTTP_AUTH_PASSWORD

accessories:
  db:
    image: postgres:15
    host: your-server.com
    directories:
      - data:/var/lib/postgresql/data
```

**Basic HTTP Authentication for MVP**:
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :authenticate if Rails.env.production?

  private

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV['HTTP_AUTH_USERNAME'] && 
      password == ENV['HTTP_AUTH_PASSWORD']
    end
  end
end
```

**Deployment Checklist**:
- Configure production database (SQLite for MVP)
- Set up environment variables
- Configure health check endpoint
- Asset precompilation settings
- Error monitoring setup (optional)

## Key Technical Decisions

### Database Design
- **Checkbox variations stored**: Each `HabitEntry` stores `checkbox_style` (1-5) and `check_style` (1-5) to mimic handwriting variance
- **User authentication**: Rails 8 built-in authentication generator with session-based auth
- **Soft deletes**: Use `active` flag on habits instead of destroying
- **Cross-month habits**: Habits can span multiple months or be tracked year-round
- **Flexible tracking**: Users can mark any habit complete on any day (past or present)

### Frontend Architecture  
- **Turbo Frames**: Month content wrapped in frame for seamless navigation
- **Turbo Streams**: Checkbox updates and reflection saves
- **Stimulus**: Thin controllers for interactions only
- **No React/Vue**: Stick to Rails defaults

### Testing Strategy
- **Model tests**: Validation, associations, business logic
- **Controller tests**: Request/response, authorization
- **Integration tests**: Request/response workflows
- **Performance tests**: Load times, interaction speed (manual)
- **Fixtures**: Comprehensive test data scenarios

### Mobile Considerations
- **Habit limit**: Start with 5 habits, test up to 10
- **Touch targets**: Minimum 44px for all interactive elements
- **Font scaling**: Prevent zoom on input focus
- **Viewport**: Fixed 412px optimization with flexible scaling

## Success Metrics

### Status: 🔴 Not Achieved

| Metric | Status | Current | Target |
|--------|--------|---------|--------|
| All tests passing | 🟡 | Style guide tests only | 100% coverage |
| Page load time (3G) | 🔴 | N/A | < 2 seconds |
| Checkbox interaction | 🔴 | N/A | < 100ms |
| Mobile viewport | 🔴 | N/A | Zero horizontal scroll at 412px |
| Kamal deployment | 🔴 | N/A | Successful deployment |
| Browser compatibility | 🔴 | N/A | iOS Safari & Chrome mobile |

## Risk Mitigation

### Performance Risks
- **SVG rendering**: Pre-optimize paths, use CSS transforms for animations
- **Database growth**: Implement database backups and monitoring
- **Memory usage**: Limit habits per month, paginate historical data

### Technical Risks  
- **Browser compatibility**: Test on real devices early
- **SQLite in production**: Plan migration path to PostgreSQL if needed
- **Touch accuracy**: Increase tap target sizes if testing shows issues

### UX Risks
- **Habit limit frustration**: Clear messaging about limits
- **Lost data**: Auto-save with visual feedback
- **Accidental deletions**: Users can simply re-check deleted entries

## Development Workflow

### Daily TDD Cycle
1. Write failing test for next feature
2. Implement minimum code to pass
3. Refactor while keeping tests green
4. Commit with descriptive message
5. Push to feature branch

### Branch Strategy
- `main` - stable, deployable code
- `feature/*` - individual features
- `fix/*` - bug fixes
- Deploy from `main` only

### Code Review Checklist
- [ ] Tests written and passing
- [ ] Mobile responsive at 412px
- [ ] Follows Rails conventions
- [ ] No unnecessary dependencies
- [ ] Performance benchmarks met

## Next Steps After MVP

### Phase 6 Enhancements (Post-MVP)
- Multiple device sync
- Export to PDF/image
- Habit templates/presets
- Analytics and progress tracking
- Sound effects for interactions
- AI-generated cover art
- Custom color themes

## Data Retention & Privacy

- **Data persistence**: All habit data retained indefinitely
- **No data deletion**: Users can deactivate but not delete habits
- **Privacy**: Basic HTTP auth ensures single-user privacy for MVP
- **Future considerations**: GDPR compliance when adding multi-user support

This plan provides a comprehensive TDD-based approach to building the Habit Tracker MVP, with tests driving the implementation at every step.