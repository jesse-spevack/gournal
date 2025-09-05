# Claude Development Guidelines

CORE TRUTH
Defensive code before functionality is theater.
Prove it works. Then protect it.

THE RULES
1. Build the Happy Path First – Code that DOES the thing
2. No Theoretical Defenses – Naked first version
3. Learn from Real Failures – Fix reality, not ghosts
4. Guard Only What Breaks – Add checks only for facts
5. Keep the Engine Visible – Action, not paranoia

ANTI-PATTERNS TO BURN
❌ Fortress Validation
❌ Defensive Exit Theater
❌ Connection State Paranoia

PATTERNS TO LIVE BY
✅ Direct Execution
✅ Natural Failure
✅ Continuous Progress

THE TEST
Can someone grok your code in 10 seconds?
YES → You lived the manifesto
NO  → Delete defenses

THE PROMISE
Readable. Debuggable. Maintainable. Honest.

THE METAPHOR
Don’t bolt on airbags before the engine runs.
First: make it move.
Then: guard against real crashes.

MAKE IT WORK FIRST.

## Typography & Font Usage

**CRITICAL DESIGN PRINCIPLE**: Fonts communicate the nature of content.

### Font Rules:
- **Typewriter Font (var(--font-mono))**: System-generated UI elements
  - Labels, buttons, headers, navigation
  - Settings options, form labels
  - Help text, instructions
  - Any static text that guides the user
  - System messages and prompts

- **Script Font (var(--font-caveat))**: User-generated content
  - Habit names (user typed)
  - Daily reflections (user typed)
  - Any text that represents user input
  - Handwritten aesthetic elements

### Capitalization Rules:
- **ALWAYS use sentence case** throughout the application
  - Headers: "Manage habits" not "Manage Habits"
  - Buttons: "Set up next month" not "Set Up Next Month"
  - Labels: "Copy current habits" not "Copy Current Habits"
  - Never use UPPERCASE for UI elements (except acronyms)
  - Title case is reserved for proper nouns only

### Examples:
```scss
// System UI - Typewriter font
.settings-section-title { font-family: var(--font-mono); }
.month-setup-label { font-family: var(--font-mono); }
.month-setup-submit { font-family: var(--font-mono); }

// User content - Script font  
.habit-name { font-family: var(--font-caveat); }
.reflection-text { font-family: var(--font-caveat); }
.habit-input { font-family: var(--font-caveat); }
```

This distinction creates a clear visual hierarchy: the system speaks in typewriter, the user writes in script.

## Service Object Pattern

When creating service objects, use the following pattern:

```ruby
class MyService
  def self.call(param1:, param2:)
    new(param1: param1, param2: param2).call
  end

  def initialize(param1:, param2:)
    @param1 = param1
    @param2 = param2
  end

  def call
    # Service logic here
  end

  private

  # Private methods here
end
```

This allows for cleaner usage: `MyService.call(param1: value1, param2: value2)` instead of `MyService.new(param1: value1, param2: value2).call`.

## Git Workflow Guidelines

**NEVER do significant feature work directly on main** - Always work on feature branches:
- Create feature branches for all work: `git checkout -b feature/feature-name`
- Use descriptive branch names that clearly indicate the work being done
- Keep main branch stable and deployable at all times

**Commit frequently and atomically**:
- Commit after completing each discrete task or subtask
- If your changeset exceeds ~100 lines, strongly consider committing
- Each commit should represent a single, complete unit of work
- Write clear, descriptive commit messages that explain the "why"

**Branch naming conventions**:
- `feature/feature-name` - New features
- `fix/issue-description` - Bug fixes  
- `refactor/component-name` - Code refactoring
- `chore/task-description` - Maintenance tasks

**Commit message format**:
```
type: brief description of change

Longer explanation if needed explaining the why and what this
enables or fixes.

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Integration workflow**:
- Create pull requests for all feature branches
- Review changes before merging to main
- Delete feature branches after successful merge

## RESTful Routing

**ALWAYS use RESTful routing patterns** - Controllers should follow REST conventions:
- Use standard actions: `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`
- For nested resources, use `module:` option to organize controllers
- Avoid custom action names when a RESTful action would work
- Use singular `resource` for single resources (e.g., positions for a habit)
- Use plural `resources` for collections

## Testing Strategy

**DO NOT implement system tests** - Focus on unit tests and integration tests only.

System tests are slow, flaky, and add unnecessary complexity. Instead:
- Write thorough unit tests for models and services
- Write integration tests for controllers
- Use request specs for testing full request/response cycles
- Manual testing for user interface validation

## TDD Approach

Follow Test-Driven Development but skip system/feature tests:
1. Write failing unit tests first
2. Implement minimal code to make tests pass
3. Refactor while keeping tests green
4. **Run `rubocop -A` after refactoring** to fix style issues
5. Verify tests still pass after rubocop fixes
6. Use integration tests for controller behavior
7. Manual testing for UI components

### Test Writing Standards

**IMPORTANT: Avoid useless variable assignments in tests**
```ruby
# BAD - variable assigned but never used
test "should do something" do
  user1 = User.create!(email: "test@example.com")
  assert User.count == 1
end

# GOOD - no unnecessary assignment
test "should do something" do
  User.create!(email: "test@example.com")
  assert User.count == 1
end

# GOOD - variable is actually used
test "should do something" do
  user = User.create!(email: "test@example.com")
  assert_equal "test@example.com", user.email
end
```

### Code Style Standards

**Avoid compound unless statements** - They're hard to read and understand:
```ruby
# BAD - compound unless is confusing
return unless completed? && habit.present?

# GOOD - use if with early return
return if !completed? || !habit.present?

# BETTER - be explicit about conditions
return if incomplete?
return if habit.blank?
```

### Code Style Enforcement

**Always run `rubocop -A` before:**
- Committing code (automatically done by `/ship` command)
- Completing a TDD cycle
- Handing off between TDD agents
- Pushing to remote

```bash
# Auto-fix all style issues
rubocop -A

# Auto-fix specific directories
rubocop -A app/
rubocop -A test/

# Check without fixing (CI mode)
rubocop
```

## Rails Testing Stack

- **Unit tests**: `test/models/`, `test/services/`, `test/helpers/`
- **Integration tests**: `test/controllers/`, `test/integration/`
- **NO system tests**: Skip `test/system/` entirely

This approach maintains quality while avoiding the overhead and brittleness of browser-based testing.

## Asset Pipeline Architecture (Rails 8 + Propshaft + Dart Sass)

### Overview
This application uses Rails 8's default Propshaft asset pipeline combined with dartsass-rails for SCSS compilation. Propshaft handles asset serving while Dart Sass handles SCSS to CSS compilation.

### Key Configuration Files

#### `app/assets/config/manifest.js`
**CRITICAL**: This file must exist for Propshaft to function. Contains:
```javascript
//= link_tree ../images
//= link_directory ../stylesheets .css
//= link_tree ../../javascript .js
//= link_tree ../builds
```

#### Layout Asset Loading
In `app/views/layouts/application.html.erb`:
```erb
<%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
```
- Use `"application"` (string) not `:app` (symbol)
- Must match the actual filename: `app/assets/stylesheets/application.css`

### CSS Build Process (Rails 8 + Propshaft + Dart Sass)

**Source Files:** Edit SCSS in `app/assets/stylesheets/`
**Compiled Output:** Auto-generated `app/assets/builds/application.css`
**Development:** Run `bin/dev` to start CSS file watcher
**Production:** `bin/rails assets:precompile` handles everything

#### Commands:
- `bin/dev` - Start development with live CSS compilation
- `bin/rails dartsass:build` - Manual one-time CSS build  
- `bin/rails dartsass:watch` - Watch for SCSS changes

### File Organization

#### CSS Structure
```
app/assets/stylesheets/
├── application.scss     # Main manifest file (imports all components)
├── config/
│   └── _design-tokens.scss   # CSS custom properties and variables
├── base/
│   └── _reset.scss          # Base styles & resets
└── components/
    ├── _checkbox.scss       # Checkbox component styles
    ├── _auth-forms.scss     # Login/signup form styles
    └── _style-guide.scss    # Style guide documentation styles
```

**IMPORTANT**: The `application.scss` file in `app/assets/stylesheets/` is the source file. Dart Sass compiles it to `app/assets/builds/application.css`, which Propshaft then serves.

#### Design System in CSS
All design tokens are defined in `application.css`:
```css
:root {
  /* Design tokens */
  --ink-primary: #1a2332;
  --paper-light: #fdfbf7;
  --checkbox-size: 24px;
  /* ... */
}

/* Component styles using design tokens */
.checkbox-custom {
  width: var(--checkbox-size);
  /* ... */
}
```

### Component Architecture

#### Partial Structure
- Reusable components as partials: `_standard_checkbox.html.erb`
- Clean separation of HTML structure and CSS styling
- CSS classes follow BEM-like naming conventions

#### Style Guide Pattern
- Style guide serves as living documentation
- Components are built once, used everywhere
- All styling happens in `application.css`, not inline

### Debugging Asset Issues

#### Common Problems
1. **Missing manifest.js**: Assets won't load at all
2. **Wrong stylesheet reference**: Using `:app` instead of `"application"`
3. **File conflicts**: Having both `.css` and `.scss` files
4. **Cache issues**: Old fingerprinted assets

#### Debugging Commands
```bash
# Check if asset is found
bin/rails runner "puts Rails.application.assets.load_path.find('application.css') ? 'FOUND' : 'NOT FOUND'"

# Check generated URL
bin/rails runner "puts ActionController::Base.helpers.stylesheet_path('application')"

# Test direct asset serving
curl -I http://localhost:3000/assets/application-[hash].css
```

### Performance Considerations

#### Propshaft Benefits
- No build step for simple CSS
- Automatic fingerprinting for cache busting
- HTTP/2 friendly (multiple small files)
- Minimal complexity compared to Sprockets

#### Best Practices
- Use CSS custom properties for theming
- Leverage modern CSS features (Grid, Flexbox, etc.)
- Progressive enhancement approach
- Mobile-first responsive design

### Migration Notes
- Propshaft does NOT transpile or bundle automatically
- No Sass/SCSS processing by default (use plain CSS or add dartsass-rails)
- No automatic dependency resolution
- Focus on modern CSS features over preprocessors

This architecture prioritizes simplicity, maintainability, and leverages Rails 8's modern defaults while building a solid foundation for an aesthetic application.

### CSS Performance Optimization

#### Build Size Verification
Check CSS build size to ensure optimization:
```bash
# Check CSS build size
ls -lh app/assets/builds/application.css | awk '{print "CSS Build Size: " $5}'

# Alternative using Rails runner
bin/rails runner "
  css_path = Rails.root.join('app/assets/builds/application.css')
  if css_path.exist?
    size = File.size(css_path) / 1024.0
    puts \"CSS Build: #{size.round(1)}KB\"
  else
    puts 'CSS Build: MISSING'
  end
"
```

**Note:** Production builds are automatically minified by dartsass-rails, reducing file size significantly.

## CSS File Organization

### Structure:
```
app/assets/stylesheets/
├── application.scss              # Main manifest file
├── config/
│   └── _design-tokens.scss      # CSS custom properties and mixins
├── base/
│   └── _reset.scss              # Base styles & resets
└── components/
    ├── _checkbox.scss           # Checkbox component styles
    ├── _auth-forms.scss         # Login/signup forms
    ├── _style-guide-layout.scss # Style guide page structure
    ├── _style-guide-demos.scss  # Component showcases
    └── _style-guide-utilities.scss # Helper classes for docs
```

### Adding New Components:
1. Create `_component-name.scss` in `components/`
2. Add `@use "components/component-name";` to `application.scss`
3. Use design tokens from `config/_design-tokens.scss`
4. Follow BEM naming: `.component`, `.component__element`, `.component--modifier`
5. Apply mobile-first responsive approach using provided mixins

### Design Token Categories:
- **Colors**: Ink and paper themed colors with opacity variations
- **Typography**: Font families, sizes, weights, and spacing
- **Spacing**: Consistent spacing scale from xxs to xxl
- **Borders**: Standardized border widths
- **Animations**: Timing functions and durations
- **Responsive**: Breakpoints and mobile-first mixins

/file:.claude-on-rails/context.md
