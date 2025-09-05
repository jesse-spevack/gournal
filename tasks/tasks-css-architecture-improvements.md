# Tasks for CSS Architecture Improvements

## Overview

Based on the comprehensive CSS audit findings, this plan addresses critical issues to improve UX/UI consistency, CSS maintainability, and fix UI bugs. The plan prioritizes high-impact fixes first, followed by architectural improvements and optimizations.

## Tasks

- [ ] 1.0 **Fix Critical CSS Issues**
  - [ ] 1.1 Define missing CSS custom properties in `_design-tokens.scss`
  - [ ] 1.2 Resolve duplicate `--space-reflection-gap` variable definition
  - [ ] 1.3 Standardize CSS property naming patterns (`--text-*` vs `--font-size-*`)
  - [ ] 1.4 Fix hardcoded magic numbers in style guide components

- [ ] 2.0 **Eliminate !important Overuse Antipattern**
  - [ ] 2.1 Audit all 31 instances of `!important` in `_settings.scss`
  - [ ] 2.2 Refactor habit input styling using proper CSS specificity
  - [ ] 2.3 Refactor month setup form styling using proper CSS specificity  
  - [ ] 2.4 Test all form interactions after removing `!important` declarations
  - [ ] 2.5 Update focus states without `!important`

- [ ] 3.0 **Remove Dead Code and Optimize Bundle**
  - [ ] 3.1 Remove unused `.blot-*` classes from `_style-guide-utilities.scss`
  - [ ] 3.2 Move style guide CSS to conditional loading in development only
  - [ ] 3.3 Remove unused design tokens (verify first)
  - [ ] 3.4 Consolidate duplicate CSS values
  - [ ] 3.5 Verify and remove unused style guide classes

- [ ] 4.0 **Improve Component Organization** 
  - [ ] 4.1 Split large `_settings.scss` (383 lines) into focused components
  - [ ] 4.2 Extract habit management styles into separate file
  - [ ] 4.3 Extract month setup styles into separate file
  - [ ] 4.4 Extract help page styles into separate file
  - [ ] 4.5 Update `application.scss` imports accordingly

- [ ] 5.0 **Establish CSS Architecture Guidelines**
  - [ ] 5.1 Document when to use `!important` (never, except for utility classes)
  - [ ] 5.2 Document BEM naming conventions vs current approach
  - [ ] 5.3 Document component boundaries and dependencies
  - [ ] 5.4 Document when to create design tokens vs hardcode values
  - [ ] 5.5 Create CSS linting rules to enforce conventions

- [ ] 6.0 **Performance and UX Optimizations**
  - [ ] 6.1 Add `&display=swap` to Google Fonts URLs in HTML head
  - [ ] 6.2 Verify ultra-subtle texture tokens are actually visible
  - [ ] 6.3 Test CSS loading performance on slow connections
  - [ ] 6.4 Implement CSS purging for unused classes in production
  - [ ] 6.5 Measure and document performance improvements

- [ ] 7.0 **Testing and Documentation**
  - [ ] 7.1 Manual test all UI components for visual consistency  
  - [ ] 7.2 Test responsive behavior across device sizes
  - [ ] 7.3 Test CSS changes in multiple browsers (Chrome, Firefox, Safari)
  - [ ] 7.4 Run CSS build process and verify no errors
  - [ ] 7.5 Update design system documentation with changes
  - [ ] 7.6 Run final CSS audit to verify improvements

## Relevant Files

### Files to be Modified:
- `app/assets/stylesheets/config/_design-tokens.scss` - Add missing variables, fix duplicates
- `app/assets/stylesheets/components/_settings.scss` - Remove !important, split into smaller files
- `app/assets/stylesheets/components/_style-guide-utilities.scss` - Remove unused .blot-* classes
- `app/assets/stylesheets/components/_style-guide-demos.scss` - Replace hardcoded values with tokens
- `app/assets/stylesheets/application.scss` - Update imports after component splitting
- `app/views/layouts/application.html.erb` - Add font-display optimization

### Files to be Created:
- `app/assets/stylesheets/components/_habit-management.scss` - Extract from _settings.scss
- `app/assets/stylesheets/components/_month-setup.scss` - Extract from _settings.scss  
- `app/assets/stylesheets/components/_help-page.scss` - Extract from _settings.scss
- `docs/css-conventions.md` - CSS architecture guidelines

### Test Files:
- Manual testing required for all UI components (no automated CSS tests)
- Browser compatibility testing required
- Performance testing on different connection speeds

## Success Criteria

- ✅ Zero `!important` declarations (except utility classes if needed)
- ✅ All CSS custom properties properly defined and used
- ✅ Build size reduced by 15-20% (target: ~20-21KB from current 25KB)
- ✅ All UI components render consistently across browsers
- ✅ CSS architecture follows documented conventions
- ✅ No visual regressions in existing functionality

## Testing Approach

Since the project uses manual testing rather than automated system tests:

1. **Component Testing**: Manually test each component in isolation
2. **Integration Testing**: Test component interactions and layouts
3. **Cross-browser Testing**: Chrome, Firefox, Safari compatibility
4. **Responsive Testing**: Mobile, tablet, desktop viewport sizes
5. **Performance Testing**: CSS load times and render performance

## Estimated Timeline

- **Phase 1 (Critical Fixes)**: 4-6 hours
- **Phase 2 (!important Elimination)**: 6-8 hours  
- **Phase 3 (Dead Code Removal)**: 2-3 hours
- **Phase 4 (Component Organization)**: 3-4 hours
- **Phase 5 (Architecture Guidelines)**: 2-3 hours
- **Phase 6 (Performance)**: 2-3 hours
- **Phase 7 (Testing)**: 4-5 hours

**Total Estimated Effort**: 23-32 hours

## Notes

- All changes should maintain the existing Japanese paper & ink aesthetic
- Preserve existing design system tokens and naming where possible
- Follow existing mobile-first responsive design patterns
- Ensure changes align with CLAUDE.md typography and font usage guidelines
- Test thoroughly since there are no automated CSS tests