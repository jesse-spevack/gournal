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