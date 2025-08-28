# Claude Development Guidelines

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
4. Use integration tests for controller behavior
5. Manual testing for UI components

## Rails Testing Stack

- **Unit tests**: `test/models/`, `test/services/`, `test/helpers/`
- **Integration tests**: `test/controllers/`, `test/integration/`
- **NO system tests**: Skip `test/system/` entirely

This approach maintains quality while avoiding the overhead and brittleness of browser-based testing.

## Asset Pipeline Architecture (Rails 8 + Propshaft)

### Overview
This application uses Rails 8's default Propshaft asset pipeline, which is fundamentally different from Sprockets. Propshaft embraces simplicity and leverages modern browser capabilities.

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

### File Organization

#### CSS Structure
```
app/assets/stylesheets/
├── application.css     # Main stylesheet with design system
└── [no .scss files]    # Avoid conflicts with Propshaft
```

**IMPORTANT**: Do not have both `application.css` and `application.scss` files. Propshaft may serve the wrong file.

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

/file:.claude-on-rails/context.md
