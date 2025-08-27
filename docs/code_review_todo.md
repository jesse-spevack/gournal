# Code Review Todo List

## 🚨 Critical Issues (Block Tests & Functionality)

### 1. Fix Template Syntax Error
- [ ] Open `app/views/style_guide/_checkbox_helper_demo.html.erb`
- [ ] Go to line 38
- [ ] Replace `escape_html` with `h` or `html_escape`
- [ ] Verify all instances are replaced (check entire file)
- [ ] Run `bin/rails test` to confirm tests pass

### 2. Resolve Asset Pipeline Configuration Conflict
- [ ] Check if both `app/assets/stylesheets/application.css` and `application.scss` exist
- [ ] If both exist, merge SCSS content into CSS file
- [ ] Delete `application.scss` file
- [ ] Ensure only `application.css` remains (per CLAUDE.md guidelines)
- [ ] Test asset loading: `bin/rails runner "puts Rails.application.assets.load_path.find('application.css') ? 'FOUND' : 'NOT FOUND'"`
- [ ] Restart Rails server and verify styles load correctly

### 3. Add Production Safety for Style Guide
- [ ] Open `app/controllers/style_guide_controller.rb`
- [ ] Update the `index` method with safe redirect:
  ```ruby
  def index
    if Rails.env.production?
      redirect_to main_app.root_path rescue redirect_to "/"
      return
    end
  end
  ```
- [ ] Verify root route exists in `config/routes.rb`

## ⚠️ Warnings (Should Fix Soon)

### 4. Remove Duplicate Favicon Declarations
- [atherinOpen `app/views/layouts/application.html.erb`
- [ ] Identify duplicate favicon links (lines 12-16 and 24-26)
- [ ] Consolidate into single set of favicon declarations
- [ ] Keep only necessary favicon formats:
  - favicon.ico (for legacy browsers)
  - favicon.svg (for modern browsers)
  - Apple touch icon (for iOS)
- [ ] Remove redundant entries

### 5. Add Parameter Validation to Checkbox Helper
- [ ] Open `app/helpers/checkbox_helper.rb`
- [ ] Add validation at the beginning of `habit_checkbox` method:
  ```ruby
  def habit_checkbox(box_variant:, fill_variant: nil, fill_style: nil)
    raise ArgumentError, "Invalid box_variant: must be 0-9" unless (0..9).include?(box_variant)
    raise ArgumentError, "Invalid fill_variant: must be 0-9" if fill_variant && !(0..9).include?(fill_variant)
    raise ArgumentError, "Invalid fill_style" if fill_style && ![:x, :check, :blot].include?(fill_style)
    # ... rest of method
  end
  ```
- [ ] Create test file `test/helpers/checkbox_helper_test.rb`
- [ ] Add tests for valid and invalid parameters
- [ ] Run helper tests to verify

### 6. Optimize Partial Rendering Performance
- [ ] Count total number of checkbox partials in `app/views/checkboxes/`
- [ ] Consider consolidating similar variants
- [ ] Add fragment caching to checkbox partials:
  ```erb
  <% cache ["checkbox", box_variant, fill_variant, fill_style] do %>
    <!-- checkbox content -->
  <% end %>
  ```
- [ ] Test performance impact with multiple checkboxes on page

## 💡 Improvements (Nice to Have)

### 7. Refactor CSS Architecture
- [ ] Create `app/assets/stylesheets/components/` directory
- [ ] Split `application.css` into logical files:
  - [ ] `design-tokens.css` (CSS custom properties)
  - [ ] `components/checkbox.css`
  - [ ] `components/style-guide.css`
  - [ ] `base/reset.css`
  - [ ] `base/typography.css`
- [ ] Update `application.css` to import component files
- [ ] Test that all styles still load correctly

### 8. Enhance Test Coverage
- [ ] Create `test/helpers/checkbox_helper_test.rb` with:
  - [ ] Test for each checkbox variant (0-9)
  - [ ] Test for each fill style (x, check, blot)
  - [ ] Test for invalid parameters
  - [ ] Test for nil optional parameters
- [ ] Add integration tests for style guide controller:
  - [ ] Test production environment redirect
  - [ ] Test development environment access
  - [ ] Test checkbox rendering in style guide
- [ ] Run full test suite: `bin/rails test`
- [ ] Check coverage report

### 9. Add Design System Documentation
- [ ] Create `docs/design_system.md`
- [ ] Document CSS custom properties and their usage
- [ ] Add checkbox variant visual guide
- [ ] Document color palette and naming conventions
- [ ] Add examples of component usage
- [ ] Include version information

### 10. Implement Design System Versioning
- [ ] Add version comments to CSS variables:
  ```css
  :root {
    /* Design System v1.0.0 */
    /* Last updated: [date] */
    /* Checkbox Components */
    --checkbox-size: 24px; /* v1.0.0 */
  }
  ```
- [ ] Create changelog for design system updates
- [ ] Document breaking changes policy

## Verification Checklist

After completing fixes:
- [ ] Run full test suite: `bin/rails test`
- [ ] Start Rails server: `bin/rails server`
- [ ] Visit style guide in development: http://localhost:3000/style_guide
- [ ] Verify all checkbox variants render correctly
- [ ] Check browser console for any errors
- [ ] Test in production mode: `RAILS_ENV=production bin/rails server`
- [ ] Verify production redirect works
- [ ] Check asset compilation: `bin/rails assets:precompile`
- [ ] Clear browser cache and test again
- [ ] Run linter if configured

## Priority Order

1. **Day 1**: Complete all Critical Issues (1-3)
2. **Day 2**: Complete all Warnings (4-6)
3. **Week 1**: Start Improvements (7-8)
4. **Week 2**: Complete remaining Improvements (9-10)

## Success Criteria

- ✅ All tests passing
- ✅ Style guide functional in development
- ✅ Safe redirect in production
- ✅ No duplicate asset declarations
- ✅ No runtime errors from invalid parameters
- ✅ Improved performance for multiple checkboxes
- ✅ Better organized CSS architecture
- ✅ >90% test coverage for helpers
- ✅ Complete design system documentation