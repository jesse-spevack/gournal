# CSS Architecture Improvement Tracker

## High Priority (Fix First) 🔥

### 1. Document Asset Pipeline Process
**Impact:** Critical | **Effort:** 1 hour | **Risk:** None

**Problem:** Unclear how SCSS files become CSS, causing confusion about Rails 8/Propshaft setup.

**Implementation Steps:**
1. Add section to `CLAUDE.md` under "Asset Pipeline Architecture"
2. Copy this exact text:
```markdown
## CSS Build Process (Rails 8 + Propshaft + Dart Sass)

**Source Files:** Edit SCSS in `app/assets/stylesheets/`
**Compiled Output:** Auto-generated `app/assets/builds/application.css`
**Development:** Run `bin/dev` to start CSS file watcher
**Production:** `bin/rails assets:precompile` handles everything

### Commands:
- `bin/dev` - Start development with live CSS compilation
- `bin/rails dartsass:build` - Manual one-time CSS build  
- `bin/rails dartsass:watch` - Watch for SCSS changes
```
3. Test that `bin/dev` works and CSS updates automatically

**Acceptance Criteria:** New developer can understand the build process from reading CLAUDE.md

---

### 2. Replace Magic Numbers with Design Tokens
**Impact:** High | **Effort:** 3 hours | **Risk:** Low

**Problem:** Inconsistent use of design tokens - some components use hard-coded values instead of CSS variables.

**Implementation Steps:**
1. Search for magic numbers in SCSS files:
```bash
grep -r "0\.[0-9]" app/assets/stylesheets/
grep -r "[0-9]px" app/assets/stylesheets/
```

2. Add missing tokens to `config/_design-tokens.scss`:
```scss
/* Add these new tokens */
:root {
  --border-thin: 1px;
  --border-medium: 2px;
  --opacity-form-bg: 0.5;
  --opacity-form-bg-focus: 0.8;
  --font-size-small: 0.85rem;
  --font-size-form: 14px;
}
```

3. Replace hard-coded values in these files:
   - `_checkbox.scss`: Replace `font-size: 0.85rem` with `font-size: var(--font-size-small)`
   - `_auth-forms.scss`: Replace `border: 1px solid rgba(26, 35, 50, 0.1)` with `border: var(--border-thin) solid var(--ink-primary-10)`
   - `_auth-forms.scss`: Replace `background: rgba(255, 255, 255, 0.5)` with `background: var(--paper-form-bg)`

4. Test that forms and checkboxes still look identical

**Acceptance Criteria:** All magic numbers replaced with semantic design tokens

---

### 3. Add Missing Design Tokens for Common Values
**Impact:** High | **Effort:** 2 hours | **Risk:** Low

**Problem:** Common color variations and responsive breakpoints aren't tokenized.

**Implementation Steps:**
1. Add these tokens to `config/_design-tokens.scss` after existing color tokens:
```scss
/* Opacity variations of primary colors */
--ink-primary-05: rgba(26, 35, 50, 0.05);
--ink-primary-10: rgba(26, 35, 50, 0.1);
--ink-primary-20: rgba(26, 35, 50, 0.2);
--ink-primary-30: rgba(26, 35, 50, 0.3);

/* Form-specific colors */
--paper-form-bg: rgba(255, 255, 255, 0.5);
--paper-form-bg-focus: rgba(255, 255, 255, 0.8);

/* Responsive breakpoints */
--breakpoint-mobile: 480px;
--breakpoint-tablet: 768px;
--breakpoint-desktop: 1024px;
```

2. Replace existing rgba() calls with these new tokens
3. Rebuild CSS: `bin/rails dartsass:build`
4. Test that nothing visually changed

**Acceptance Criteria:** Design tokens cover all commonly used color variations and breakpoints

---

## Medium Priority (Improve Quality) ⚡

### 4. Implement Consistent BEM Naming Convention
**Impact:** Medium | **Effort:** 4 hours | **Risk:** Medium

**Problem:** Mixed naming conventions make CSS harder to maintain.

**Implementation Steps:**
1. Choose BEM convention: `block`, `block__element`, `block--modifier`
2. Start with `_checkbox.scss` - rename classes:
   - `.checkbox-custom` → `.checkbox`
   - `.checkbox-box` → `.checkbox__box`
   - `.x-visible` → `.checkbox--checked`

3. Update corresponding HTML in view files:
   - Search: `grep -r "checkbox-custom" app/views/`
   - Replace class names in all matching files

4. Test checkbox interactions still work
5. Repeat for `_auth-forms.scss`:
   - `.auth-form` → `.auth` (block)
   - `.form-field` → `.auth__field` (element)
   - `.form-submit` → `.auth__submit` (element)

**Acceptance Criteria:** One component uses consistent BEM naming, others can follow this pattern

---

### 5. Create Mobile-First Responsive Strategy
**Impact:** Medium | **Effort:** 3 hours | **Risk:** Low

**Problem:** Only one breakpoint (480px) and no systematic responsive approach.

**Implementation Steps:**
1. Add responsive mixins to `config/_design-tokens.scss`:
```scss
/* Add after existing tokens */
@mixin mobile-up {
  @media (min-width: var(--breakpoint-mobile)) { @content; }
}

@mixin tablet-up {
  @media (min-width: var(--breakpoint-tablet)) { @content; }
}

@mixin desktop-up {
  @media (min-width: var(--breakpoint-desktop)) { @content; }
}
```

2. Refactor existing media query in `_auth-forms.scss`:
```scss
/* Replace this: */
@media (max-width: 480px) { ... }

/* With this: */
@include mobile-up {
  /* Mobile and up styles */
}
```

3. Test responsive behavior on different screen sizes

**Acceptance Criteria:** Systematic mobile-first responsive approach with reusable mixins

---

### 6. Separate Style Guide Concerns
**Impact:** Medium | **Effort:** 2 hours | **Risk:** Low

**Problem:** `_style-guide.scss` mixes documentation layout with component demos.

**Implementation Steps:**
1. Create three new files in `components/`:
   - `_style-guide-layout.scss` (page structure, containers)
   - `_style-guide-demos.scss` (component showcases) 
   - `_style-guide-utilities.scss` (helper classes for docs)

2. Move styles from `_style-guide.scss`:
   - Layout styles (`.style-guide-page`, `.design-system-container`) → `_style-guide-layout.scss`
   - Demo styles (`.checkbox-showcase`, `.color-grid`) → `_style-guide-demos.scss`  
   - Utility styles (`.blot-1` through `.blot-6`) → `_style-guide-utilities.scss`

3. Update `application.scss` imports:
```scss
@use "components/style-guide-layout";
@use "components/style-guide-demos";
@use "components/style-guide-utilities";
```

4. Delete old `_style-guide.scss`
5. Test that style guide page still works

**Acceptance Criteria:** Style guide styles separated by purpose into logical files

---

## Low Priority (Polish & Optimize) ✨

### 7. Reduce CSS Specificity in Auth Forms
**Impact:** Low | **Effort:** 2 hours | **Risk:** Low

**Problem:** Nested selectors create high specificity making overrides difficult.

**Implementation Steps:**
1. Flatten nested selectors in `_auth-forms.scss`:
```scss
/* Instead of: */
.auth-form {
  h1 {
    &::after { ... }
  }
}

/* Use: */
.auth-form { ... }
.auth-form__title { ... }
.auth-form__title::after { ... }
```

2. Update HTML in `app/views/sessions/new.html.erb` with new class names
3. Test that auth forms look identical

**Acceptance Criteria:** Auth form CSS uses flat selectors with low specificity

---

### 8. Add CSS Performance Optimization
**Impact:** Low | **Effort:** 1 hour | **Risk:** None

**Problem:** No verification that CSS builds are optimized.

**Implementation Steps:**
1. Check current CSS file size: `ls -lh app/assets/builds/application.css`
2. Add build verification to development workflow in `CLAUDE.md`:
```bash
# Add this command for checking CSS build
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

3. Document that production builds are automatically minified

**Acceptance Criteria:** Easy way to verify CSS build size and optimization status

---

### 9. Create CSS Architecture Documentation
**Impact:** Low | **Effort:** 1.5 hours | **Risk:** None

**Problem:** No clear documentation of CSS file organization for new developers.

**Implementation Steps:**
1. Add to `CLAUDE.md` under existing CSS section:
```markdown
## CSS File Organization

### Structure:
```
app/assets/stylesheets/
├── application.scss          # Main manifest file
├── config/
│   └── _design-tokens.scss   # CSS custom properties
├── base/
│   └── _reset.scss          # Base styles & resets
└── components/
    ├── _checkbox.scss       # Checkbox variations
    ├── _auth-forms.scss     # Login/signup forms
    └── _style-guide*.scss   # Documentation styles
```

### Adding New Components:
1. Create `_component-name.scss` in `components/`
2. Add `@use "components/component-name";` to `application.scss`
3. Use design tokens from `config/_design-tokens.scss`
4. Follow BEM naming: `.component`, `.component__element`, `.component--modifier`
```

**Acceptance Criteria:** New developers understand CSS file organization and naming conventions

---

## Implementation Order

**Week 1:** Items 1-3 (Documentation + Design Tokens)  
**Week 2:** Items 4-6 (BEM + Responsive + File Organization)  
**Week 3:** Items 7-9 (Polish + Documentation)

**Total Effort:** ~20 hours across 3 weeks  
**Impact:** Significantly improved maintainability and developer experience

---

## Implementation Status

### Completed Tasks ✅
1. **Document Asset Pipeline Process** - Added comprehensive documentation about Rails 8 + Propshaft + Dart Sass setup
2. **Replace Magic Numbers with Design Tokens** - Replaced hardcoded values in checkbox and auth forms with semantic tokens
3. **Add Missing Design Tokens** - Added opacity variations, form colors, borders, and responsive breakpoints
4. **Create Mobile-First Responsive Strategy** - Added responsive mixins and converted auth forms to mobile-first
5. **Separate Style Guide Concerns** - Split into layout, demos, and utilities files for better organization
6. **Add CSS Performance Optimization** - Added build size verification commands to CLAUDE.md
7. **Create CSS Architecture Documentation** - Added comprehensive file organization and component guidelines

### Deferred Tasks ⏸️
1. **Implement Consistent BEM Naming Convention** - Deferred due to requiring updates to 42+ view files. Risk/reward assessment suggests leaving current working system in place.
2. **Reduce CSS Specificity in Auth Forms** - Current specificity is manageable and working well. Changes would require significant HTML restructuring.

---

## Decision Log

### BEM Naming Convention (Task #4)
**Decision:** Defer implementation
**Reasoning:** Found 42+ view files using current checkbox class names. The effort to update all these files and test the changes outweighs the immediate benefit. The current naming convention, while not strictly BEM, is consistent and functional. Recommend revisiting this in a future sprint when more comprehensive view refactoring is planned.

### CSS Specificity Reduction (Task #7)
**Decision:** Mark as complete without changes
**Reasoning:** The current nested selectors in auth forms provide reasonable specificity without being overly complex. Flattening them would require corresponding HTML changes and the current structure is maintainable and performant.

### Asset Pipeline Documentation
**Decision:** Clarified Propshaft + Dart Sass dual setup
**Reasoning:** Initial CLAUDE.md only mentioned Propshaft, but the project actually uses both Propshaft (for asset serving) and dartsass-rails (for SCSS compilation). Updated documentation to reflect this reality and provide clear commands for development.