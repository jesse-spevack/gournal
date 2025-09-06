# Gournal Design System

> A Japanese paper & ink themed design system for mindful journaling

## Overview

The Gournal design system embodies the aesthetic of traditional Japanese paper and fountain pen ink, creating a calm, focused environment for digital journaling. This system emphasizes organic textures, subtle variations, and thoughtful typography to mirror the experience of writing on high-quality washi paper.

## Design Philosophy

### Core Principles
- **Organic Beauty**: Inspired by handmade Japanese paper with natural fiber textures
- **Mindful Focus**: Calming colors that promote concentration and reflection
- **Authentic Feel**: Hand-drawn style elements that feel personal and unique
- **Respectful Minimalism**: Clean interfaces that honor the content

### Aesthetic Goals
- Evoke the tactile experience of premium stationery
- Create visual rhythm through consistent spacing and typography
- Maintain legibility while adding character through subtle imperfections
- Support long-form writing with comfortable contrast ratios

## Color Palette

### Primary Ink Colors
Our primary colors are inspired by high-quality fountain pen inks:

```css
--ink-primary: #1a2332    /* Main fountain pen ink color */
--ink-hover: #0f1821      /* Darker ink on hover/checked */
```

- **Usage**: Text, icons, line art, interactive elements
- **Accessibility**: WCAG AA compliant contrast on paper backgrounds
- **Character**: Deep, rich tones that feel substantial yet organic

### Paper Background Colors
Three tones of Japanese washi paper, each with subtle warmth:

```css
--paper-light: #fdfbf7    /* Lightest washi paper tone */
--paper-mid: #f8f5ed      /* Mid-tone paper */
--paper-dark: #f3ede3     /* Darkest paper tone */
```

- **Usage**: Backgrounds, cards, input fields
- **Progression**: Light to dark creates subtle visual hierarchy
- **Warmth**: Slight cream/beige tints add comfort over pure white

### Container & Texture Colors
Layered transparency creates depth and paper-like texture:

```css
--container-top: rgba(255, 254, 252, 0.85)
--container-mid: rgba(255, 253, 250, 0.75) 
--container-bottom: rgba(252, 250, 246, 0.8)

--fiber-dark: rgba(165, 155, 135, 0.02)
--fiber-mid: rgba(145, 135, 115, 0.015)
--fiber-light: rgba(125, 115, 95, 0.01)
```

- **Usage**: Overlay effects, subtle texture, depth perception
- **Technique**: Very low opacity creates paper fiber illusion

### Shadows & Depth
Soft shadows that suggest paper thickness and natural lighting:

```css
--shadow-subtle: rgba(0, 0, 0, 0.08)
--shadow-light: rgba(0, 0, 0, 0.03)  
--shadow-medium: rgba(0, 0, 0, 0.05)
--shadow-focus: rgba(30, 40, 50, 0.15)
```

## Typography

### Font Families

```css
--font-serif: 'Special Elite', 'Georgia', serif        /* Typewriter aesthetic */
--font-mono: 'Special Elite', 'Courier New', monospace /* Typewriter aesthetic */  
--font-caveat: 'Caveat', 'Courier New', cursive       /* Handwritten reflections */
```

**Special Elite**
- Primary typewriter font for all UI elements
- Headers, labels, and interface text
- Vintage typewriter aesthetic throughout
- Consistent character adds authenticity

**Caveat Handwritten**  
- Used exclusively for daily reflections
- Personal, handwritten journal feel
- Size increased to 18px for readability
- Creates beautiful contrast with typewriter elements

### Font Sizes & Hierarchy

```css
--text-xs: 11px          /* STANDARD UI SIZE - All typewriter interface text */
--text-reflection: 12px  /* Reflection text, captions */
--text-sm: 16px          /* Headers, emphasis text */
```

**Standard Typewriter UI Font Size**
- `--text-xs` (11px) is the **default size for all typewriter UI elements**
- Used for: headers, labels, buttons, settings, context menus, navigation
- Creates consistent visual hierarchy across all system-generated content
- Matches the "Settings" header size throughout the application

**Size Strategy**
- Limited scale maintains cohesion
- Small sizes for metadata preserve focus on content
- Generous base size (16px+) supports extended reading

### Letter Spacing & Rhythm

```css
--letter-spacing-tight: 0.2px   /* Condensed text, headers */
--letter-spacing-normal: 0.3px  /* Standard body text */
--letter-spacing-wide: 0.5px    /* Expanded text, labels */
```

## Spacing System

### Philosophy
Spacing follows a harmonious scale based on multiples of small units, creating consistent rhythm throughout the interface.

### Micro Spacing
```css
--space-xxs: 1px    /* Hairline borders, fine details */
--space-xs: 2px     /* Tight spacing, inline elements */ 
--space-sm: 4px     /* Small gaps, padding */
```

### Component Spacing  
```css
--space-checkbox-gap: 0px      /* No gap between checkboxes for tighter layout */
--space-column-gap: 4px        /* Between layout columns */
--space-number-margin: 12px    /* Between day numbers and checkboxes */
--space-reflection-gap: 0px    /* No gap before reflection column */
```

### Layout Spacing
```css
--space-md: 15px     /* Standard margin/padding */
--space-lg: 20px     /* Section separation */
--space-xl: 40px     /* Major layout gaps */
--space-xxl: 80px    /* Page-level spacing */
```

## Checkbox Component System

### Core Philosophy
Checkboxes are central to the journaling experience, designed to feel like hand-drawn boxes on paper with personal character.

### Dimensions
```css
--checkbox-size: 24px        /* Slightly larger for better visibility */
--checkbox-viewbox: 24       /* SVG viewBox dimension */
--checkbox-gap: 0px          /* No gap between checkboxes for tighter layout */
```

### Visual Variants

**Box Styles (0-9)**
- Ten different hand-drawn box outlines
- Subtle variations in corner radius and line weight
- Each maintains same functional size but unique character
- Randomly distributed to create organic, non-repetitive layouts

**Fill Styles** 
- `:x` - Hand-drawn X marks with varying stroke weights
- `:blot` - Ink blot fills with organic, irregular shapes
- Future: `:check` - Checkmark style (planned)

### Stroke Properties
```css
--stroke-width-base: 1.4     /* Standard outline weight */
--stroke-width-hover: 1.6    /* Hover state emphasis */

--stroke-x-thin: 1.9         /* Lightest X mark */
--stroke-x-regular: 2.0      /* Standard X mark */
--stroke-x-medium: 2.2       /* Medium emphasis */
--stroke-x-bold: 2.4         /* Strong emphasis */  
--stroke-x-heavy: 2.6        /* Maximum emphasis */
```

### Opacity Scale
```css
--opacity-checkbox: 0.85         /* Standard checkbox visibility */
--opacity-checkbox-hover: 0.95   /* Hover state enhancement */
```

### Interactive States
- **Default**: Soft presence that doesn't compete with content
- **Hover**: Subtle darkening and stroke weight increase
- **Checked**: X mark or blot appears with smooth animation
- **Focus**: Maintained accessibility without harsh outlines

## Animation & Transitions

### Timing Functions
```css
--ease-standard: cubic-bezier(0.4, 0, 0.2, 1)      /* Standard easing */
--ease-bounce: cubic-bezier(0.68, -0.55, 0.265, 1.55) /* Playful bounce */
```

### Durations
```css
--duration-fast: 0.26s       /* Quick interactions */
--duration-normal: 0.3s      /* Standard transitions */
--duration-slow: 0.35s       /* Emphasized changes */
```

### Animation Principles
- **Subtle**: Animations enhance without distracting
- **Organic**: Bounce easing adds life to checkbox interactions  
- **Purposeful**: Each animation serves a functional purpose
- **Respectful**: Never interferes with reading or writing

## Grid & Layout

### Container System
```css
--container-max-width: 1200px   /* Maximum content width */
--container-min-height: 100vh   /* Full viewport height */
```

### Grid Patterns
```css
--grid-dot-size: 1.2px      /* Subtle dot grid size */
--grid-spacing: 24px        /* Grid interval spacing */
```

**Grid Usage**
- Checkbox layouts use auto-fill grids with minimum column widths
- Flexible layouts adapt to content and screen size
- Grid spacing aligns with overall spacing system

## Daily Reflections Component

### Design Philosophy
Daily reflections use a completely invisible contenteditable div approach to maximize the bullet journal aesthetic:

```css
.reflection-input {
  font-family: var(--font-caveat);
  font-size: 18px;
  background: transparent;
  border: none;
  text-overflow: ellipsis;
  white-space: nowrap;
  overflow: hidden;
}
```

### Key Features
- **Invisible Interface**: No borders, backgrounds, or scrollbars
- **Handwritten Font**: Caveat font with Courier New fallback for personal journal feel
- **Elegant Ellipsis**: Native CSS ellipsis truncation when unfocused
- **Single-line Input**: Prevents line breaks, maintains clean layout
- **Auto-save**: 500ms debounced saving
- **Subtle Feedback**: Opacity changes for save status

### Technical Implementation
- **ContentEditable**: Uses `contenteditable="true"` div instead of textarea for proper ellipsis support
- **Fallback Fonts**: Graceful degradation with `'Caveat', 'Courier New', cursive`
- **Font Loading**: Optimized loading with `display=block` to prevent flickering

### Interactive States
- **Default**: Single line with ellipsis (...) when text overflows
- **Focus**: Expands to show full content with horizontal scrolling
- **Saving**: Slight opacity reduction (0.8)
- **Error**: Further opacity reduction (0.6)

## Layout Simplifications

### Container Updates
The container system has been simplified for maximum screen utilization:

```css
.container {
  padding: var(--space-md);  /* Minimal padding only */
  /* Removed: max-width, centering, background, border-radius */
}
```

### Visual Minimalism
- **No Hover Effects**: Removed row hover highlighting
- **No Borders**: Removed header/content separator lines
- **No Focus Highlights**: Textareas blend seamlessly
- **Full Width**: Content uses entire viewport width

## Component Architecture

### File Organization
```
app/assets/stylesheets/
├── application.scss              # Main manifest
├── config/
│   └── _design-tokens.scss       # All design tokens
├── base/  
│   └── _reset.scss               # Base styles
└── components/
    ├── _checkbox.scss            # Checkbox system
    └── _style-guide.scss         # Documentation styles
```

### CSS Custom Properties
All design tokens are defined as CSS custom properties (CSS variables) for:
- **Consistency**: Single source of truth for values
- **Maintainability**: Easy updates across entire system  
- **Theming**: Potential for future theme variations
- **Performance**: No preprocessing required

### Component Design
- **Modular**: Each component is self-contained
- **Composable**: Components work together harmoniously
- **Accessible**: ARIA compliance and keyboard navigation
- **Flexible**: Adapts to different contexts and content

## Usage Guidelines

### Do's
✅ Use design tokens consistently across all components  
✅ Maintain the organic, hand-drawn aesthetic in new elements  
✅ Test readability across different screen sizes and conditions  
✅ Preserve the calm, focused atmosphere in interface decisions  
✅ Follow the established spacing rhythm in layouts

### Don'ts  
❌ Don't use harsh, digital-feeling elements  
❌ Don't break the established color harmony  
❌ Don't create overly complex or distracting animations  
❌ Don't ignore accessibility requirements  
❌ Don't mix different visual styles within the same interface

## Accessibility

### Color Contrast
- All text meets WCAG AA standards (4.5:1 minimum)
- Interactive elements have sufficient contrast in all states
- Focus indicators are visible without being intrusive

### Typography  
- Base font sizes support comfortable reading
- Line spacing provides adequate rhythm for extended text
- Font choices prioritize legibility over decoration

### Interaction
- Touch targets meet minimum size requirements (24px+)
- Keyboard navigation is fully supported
- Screen reader compatibility maintained

## Browser Support

### Modern Browsers
- Chrome 90+
- Firefox 88+ 
- Safari 14+
- Edge 90+

### CSS Features Used
- CSS Custom Properties (CSS Variables)
- CSS Grid and Flexbox
- CSS Transforms and Transitions  
- SVG integration

### Graceful Degradation
- System fonts fallback for custom typography
- Basic functionality maintained without advanced CSS features
- Progressive enhancement approach

## Implementation Examples

### Basic Checkbox Usage
```erb
<%= habit_checkbox(box_variant: 7, fill_variant: 2, fill_style: :x) %>
<%= habit_checkbox(box_variant: 1, fill_variant: 5, fill_style: :blot) %>
```

### Color Usage
```css
.custom-element {
  background: var(--paper-light);
  color: var(--ink-primary);
  box-shadow: 0 2px 8px var(--shadow-subtle);
  border-radius: 8px;
}
```

### Typography Patterns
```css
.heading {
  font-family: var(--font-serif);
  font-size: var(--text-sm);
  letter-spacing: var(--letter-spacing-tight);
  color: var(--ink-primary);
}

.metadata {
  font-family: var(--font-mono);  
  font-size: var(--text-xs);
  opacity: var(--opacity-numbers);
  color: var(--ink-primary);
}
```

## Versioning & Updates

### Current Version
**Design System v1.1.0** (2025-09-01)

### Recent Updates (v1.1.0)
- Changed primary font to Special Elite (typewriter aesthetic)
- Added Caveat font for daily reflections (handwritten feel)
- Removed visual containers and borders for minimalism
- Eliminated hover effects for authentic bullet journal experience
- Increased checkbox size to 24px with 0px gap
- Made reflection textareas completely invisible
- Simplified container system for full-width layouts

### Versioning Scheme
- **Major (2.0.0)**: Breaking changes to core tokens or component structure
- **Minor (1.x.0)**: New tokens, components, or non-breaking enhancements
- **Patch (1.0.x)**: Bug fixes, documentation updates, minor adjustments

### Change Management
- All changes are documented in `DESIGN_CHANGELOG.md`
- Version comments in CSS indicate when tokens were introduced or modified
- Breaking changes require migration guide and deprecation period

---

*This design system reflects the calm, focused spirit of traditional journaling while embracing modern web capabilities. It serves as both a technical reference and a creative foundation for the Gournal experience.*