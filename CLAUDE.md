# Claude Development Guidelines

## Core Philosophy
**Build the happy path first. Prove it works. Then protect it.**

### The Rules
1. **Direct Execution** - Code that DOES the thing
2. **No Theoretical Defenses** - Naked first version
3. **Learn from Real Failures** - Fix reality, not ghosts
4. **Guard Only What Breaks** - Add checks only for facts
5. **Keep the Engine Visible** - Action, not paranoia

**The Test:** Can someone grok your code in 10 seconds?

## Git Workflow

### Branch Strategy
- **Never work directly on main** - Always use feature branches
- Branch naming: `feature/`, `fix/`, `refactor/`, `chore/`
- Delete branches after merge

### Commit Practice
- Commit atomically (~100 lines max per commit)
- Each commit = one complete unit of work
- Format:
  ```
  type: brief description
  
  Longer explanation if needed
  
  🤖 Generated with Claude Code
  Co-Authored-By: Claude <noreply@anthropic.com>
  ```

## Rails Architecture

### RESTful Routing
- Use standard actions: `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`
- Avoid custom action names
- Use `resource` for singles, `resources` for collections

### Service Objects
```ruby
class MyService
  def self.call(param1:, param2:)
    new(param1:, param2:).call
  end

  def initialize(param1:, param2:)
    @param1 = param1
    @param2 = param2
  end

  def call
    # Service logic here
  end

  private
  # Private methods
end
```

## Testing Strategy

### TDD Approach
1. Write failing unit tests first
2. Implement minimal code to pass
3. Refactor while keeping tests green
4. **Run `rubocop -A` after refactoring**
5. Manual testing for UI validation

### Test Types
- **Unit tests**: Models, services, helpers
- **Integration tests**: Controllers, request specs
- **NO system tests**: Skip browser-based testing

### Test Standards
```ruby
# BAD - useless variable assignment
test "creates user" do
  user1 = User.create!(email: "test@example.com")
  assert User.count == 1
end

# GOOD - no unnecessary assignment
test "creates user" do
  User.create!(email: "test@example.com")
  assert User.count == 1
end
```

## Code Style

### Clarity Over Cleverness
```ruby
# BAD - compound unless is confusing
return unless completed? && habit.present?

# GOOD - explicit conditions
return if incomplete?
return if habit.blank?
```

### Style Enforcement
Always run `rubocop -A` before:
- Committing code
- Completing TDD cycle
- Pushing to remote

## Asset Pipeline (Rails 8 + Propshaft + Dart Sass)

### Key Files
- **Manifest**: `app/assets/config/manifest.js` (required for Propshaft)
- **Source**: `app/assets/stylesheets/application.scss`
- **Compiled**: `app/assets/builds/application.css` (auto-generated)

### Development Commands
```bash
bin/dev                    # Start with live CSS compilation
bin/rails dartsass:build   # Manual CSS build
bin/rails dartsass:watch   # Watch for SCSS changes
```

### CSS Architecture
```
app/assets/stylesheets/
├── application.scss              # Main manifest
├── config/
│   └── _design-tokens.scss      # CSS variables & mixins
├── base/
│   └── _reset.scss              # Base styles
└── components/
    └── _component-name.scss     # Component styles
```

### Adding Components
1. Create `_component-name.scss` in `components/`
2. Add `@use "components/component-name";` to `application.scss`
3. Use design tokens from `config/_design-tokens.scss`
4. Follow BEM naming conventions
5. Mobile-first responsive approach

## Typography & Design System

### Required Reading Before View Work
**Always review these files before working on views:**
- `docs/design_system.md` - Complete design system documentation
- `app/views/shared/` - Reusable view partials and components
- `app/views/style_guide/` - Living style guide with component examples

### Font Rules
- **Typewriter Font** (`var(--font-mono)`): System UI elements
  - Labels, buttons, headers, navigation
  - Standard size: `var(--text-xs)` (11px)
  
- **Script Font** (`var(--font-caveat)`): User-generated content
  - Habit names, reflections, user input

### Capitalization
- **Always use sentence case** throughout the application
- Never use UPPERCASE (except acronyms)
- Title case only for proper nouns

### Design Tokens
All design tokens defined in CSS custom properties:
```css
:root {
  --ink-primary: #1a2332;
  --paper-light: #fdfbf7;
  --checkbox-size: 24px;
  /* ... */
}
```

## Debugging

### Asset Issues
```bash
# Check if asset is found
bin/rails runner "puts Rails.application.assets.load_path.find('application.css')"

# Check CSS build size
ls -lh app/assets/builds/application.css | awk '{print $5}'
```

### Common Problems
1. Missing `manifest.js` - Assets won't load
2. Wrong stylesheet reference - Use `"application"` not `:app`
3. File conflicts - Avoid both `.css` and `.scss` versions
4. Cache issues - Clear old fingerprinted assets

## Key Principles

1. **Readable > Clever** - Code should be immediately understandable
2. **Test the reality** - Focus on actual behavior, not theoretical edge cases
3. **Commit frequently** - Small, atomic commits with clear messages
4. **RESTful by default** - Standard patterns over custom solutions
5. **Manual UI testing** - Skip brittle system tests
6. **Design tokens everywhere** - Consistent visual language
7. **Sentence case UI** - Friendly, not shouty

## View Development Guidelines

### Required Reading Before View Work
**Always review these files before working on views:**
- `docs/design_system.md` - Complete design system documentation
- `app/views/shared/` - Reusable view partials and components
- `app/views/style_guide/` - Living style guide with component examples

### Typography & Font Rules
- **Typewriter Font** (`var(--font-mono)`): System UI elements
  - Labels, buttons, headers, navigation, day numbers
  - Standard size: `var(--text-xs)` (11px) for ALL UI elements
  - Never use larger fonts to simulate "old typewriters"
  
- **Script Font** (`var(--font-caveat)`): User-generated content
  - Habit names, reflections, user input
  - Size: 18px for readability

### Button System
Use shared button partials for all buttons:
- `shared/primary_button` - Main actions (Save, Create, Submit)
- `shared/secondary_button` - Less prominent actions (Cancel, Links)  
- `shared/context_button` - Menu items with danger/cancel variants
- `shared/navigation_button` - Back links, help buttons (variants: 'nav', 'help')

```erb
<%= render 'shared/primary_button', text: 'Save settings', type: 'submit' %>
<%= render 'shared/secondary_button', text: 'Cancel', url: root_path %>
<%= render 'shared/navigation_button', text: '(?)', variant: 'help', url: help_path %>
```

### Layout Patterns

#### Paper Background Structure
All main pages use this hierarchy:
```erb
<div class="paper-background">
  <div class="container">
    <div class="dot-grid-overlay">
      <header class="month-header">
        <h1>Page Title</h1>
      </header>
      <!-- Page content -->
    </div>
  </div>
</div>
```

#### Habit Tracking Grid
Checkboxes appear in structured vertical grids:
- Day numbers on left (11px font-mono)
- Habits in columns with minimal spacing (4px gaps)
- No background containers around checkbox groups
- Use `habit_checkbox` helper for all checkbox rendering

#### Form Patterns
- Auth forms: Use button partials with `width: 100%` styling
- Settings forms: Primary buttons for submit, secondary for cancel
- Inline forms: Navigation buttons for help/utility actions

### Spacing & Visual Hierarchy
- Use design tokens: `var(--space-xs)`, `var(--space-sm)`, etc.
- Checkbox gaps: 0px vertical, 4px horizontal (`--space-checkbox-gap`)
- No decorative containers - clean paper aesthetic
- Minimal visual hierarchy - content over decoration

### Component Integration
- Always use existing partials from `app/views/shared/`
- Check style guide for component demonstrations
- Follow existing patterns in similar views
- Integrate with Stimulus controllers when needed

### Capitalization
- **Always use sentence case** throughout the application
- Never use UPPERCASE (except acronyms)
- Title case only for proper nouns

## Quick Reference

### Commands
```bash
bin/dev                    # Start development
rubocop -A                 # Fix style issues
bin/rails test            # Run tests
bin/rails dartsass:build # Build CSS
```

### File Locations
- Controllers: `app/controllers/`
- Models: `app/models/`
- Services: `app/services/`
- Views: `app/views/`
- Styles: `app/assets/stylesheets/`
- Tests: `test/`

### Workflow Checklist
- [ ] Feature branch created
- [ ] Tests written first (TDD)
- [ ] Code implemented
- [ ] Rubocop run
- [ ] Tests passing
- [ ] Manual UI check
- [ ] Commit with clear message
- [ ] PR created for review