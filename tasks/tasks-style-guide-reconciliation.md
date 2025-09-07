# Tasks for Style Guide Reconciliation

## Tasks

- [x] 1.0 Update checkbox demonstrations to match actual usage patterns
  - [x] 1.1 Replace horizontal checkbox grids with vertical layout
  - [x] 1.2 Update CSS to use flexbox instead of grid layout
  - [x] 1.3 Remove large spacing between checkbox items
  - [x] 1.4 Update checkbox demo item styling to match habit grid

- [x] 2.0 Remove style guide container backgrounds and decorative elements  
  - [x] 2.1 Remove .checkbox-showcase background gradients
  - [x] 2.2 Remove excessive padding from demo containers
  - [x] 2.3 Remove decorative border-radius styling
  - [x] 2.4 Update to match clean paper background aesthetic

- [ ] 3.0 Create realistic habit tracking context demos
  - [x] 3.1 Add "Habit Tracking Context" section to checkbox demo
  - [x] 3.2 Create mini habit grid example with day numbers
  - [ ] 3.3 Show checkboxes in actual row/column structure
  - [ ] 3.4 Add habit name headers as in real implementation

- [ ] 4.0 Align style guide spacing with design system specifications
  - [ ] 4.1 Update checkbox gaps to use --space-checkbox-gap (0px)
  - [ ] 4.2 Update column spacing to use --space-column-gap (4px)
  - [ ] 4.3 Remove minmax grid sizing, use actual checkbox dimensions
  - [ ] 4.4 Ensure consistent spacing with habit-tracking-layout.scss

- [ ] 5.0 Add educational sections for component variations
  - [ ] 5.1 Keep individual variation showcases for developers
  - [ ] 5.2 Add section explaining gap between components and usage
  - [ ] 5.3 Document when to use individual partials vs habit_checkbox helper
  - [ ] 5.4 Add notes about production layout patterns

- [ ] 6.0 Testing and validation
  - [ ] 6.1 Run style guide controller tests
  - [ ] 6.2 Verify all checkbox variations still render correctly
  - [ ] 6.3 Test responsive behavior on mobile
  - [ ] 6.4 Validate against design system documentation

## Relevant Files

- `app/views/style_guide/_checkbox_demo.html.erb` - Main checkbox demonstration file
- `app/assets/stylesheets/components/_style-guide-demos.scss` - Style guide specific CSS
- `test/controllers/style_guide_controller_test.rb` - Style guide tests
- `docs/design_system.md` - Design system reference for validation