# Layout Structure Documentation

## ASCII Layout Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              Japanese Paper Background                               │
│  ┌───────────────────────────────────────────────────────────────────────────────┐  │
│  │                        Container (1200px max-width)                           │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────┐  │  │
│  │  │                        Dot Grid Overlay                                 │  │  │
│  │  │                                                                         │  │  │
│  │  │  ╔═══════════════════════════════════════════════════════════════════╗  │  │  │
│  │  │  ║                         COVER ART                                 ║  │  │  │
│  │  │  ║                                                                   ║  │  │  │
│  │  │  ║     ◇ B U L L E T   J O U R N A L   H A B I T   T R A C K E R ◇   ║  │  │  │
│  │  │  ║                                                                   ║  │  │  │
│  │  │  ║       ～ M I N D F U L   D A I L Y   P R A C T I C E ～         ║  │  │  │
│  │  │  ║                                                                   ║  │  │  │
│  │  │  ║                           ✦                                       ║  │  │  │
│  │  │  ║                      Month / Year                                 ║  │  │  │
│  │  │  ║                           ✦                                       ║  │  │  │
│  │  │  ╚═══════════════════════════════════════════════════════════════════╝  │  │  │
│  │  │                                                                         │  │  │
│  │  │  ┌───┐ ┌───┐ ┌──────┐              ┌─────────────────────────────────┐  │  │  │
│  │  │  │ N │ │ S │ │ Bed  │              │          Reflection             │  │  │  │
│  │  │  │ u │ │ t │ │  <   │              │                                 │  │  │  │
│  │  │  │ t │ │ r │ │ 10pm │              │                                 │  │  │  │
│  │  │  │ r │ │ e │ │      │              │                                 │  │  │  │
│  │  │  │ i │ │ t │ │      │              │                                 │  │  │  │
│  │  │  │ t │ │ c │ │      │              │                                 │  │  │  │
│  │  │  │ i │ │ h │ │      │              │                                 │  │  │  │
│  │  │  │ o │ │   │ │      │              │                                 │  │  │  │
│  │  │  │ n │ │   │ │      │              │                                 │  │  │  │
│  │  │  └───┘ └───┘ └──────┘──────────────┴─────────────────────────────────┘  │  │  │
│  │  │                                                                         │  │  │
│  │  │   1□    □      □     │ Started the day with green smoothie and felt... │  │  │
│  │  │   2□    □      □     │ Skipped breakfast but had nutritious lunch. S...│  │  │
│  │  │   3□    □      □     │                                                 │  │  │
│  │  │   4□    □      □     │                                                 │  │  │
│  │  │   5□    □      □     │                                                 │  │  │
│  │  │   ...                │                                                 │  │  │
│  │  │  31□    □      □     │                                                 │  │  │
│  │  │                     │                                                 │  │  │
│  │  │                                                                  和紙 │  │  │
│  │  └─────────────────────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## Scalable Design Pattern

### Habit Columns
- Each habit follows same pattern:
- 4px gap between habit columns
- First column includes day numbers (1-31)
- Subsequent columns are checkboxes only
- All use same header rotation (-90°) and alignment

### Reflection Column
- Always separated by 8px gap from last habit
- Uses flex-grow: 1 to fill remaining space
- Horizontal header alignment
- Single-line text with ellipsis truncation

## Column Specifications

| Column | Header | Content | Spacing | Alignment |
|--------|--------|---------|---------|-----------|
| First Habit | Rotated -90° | Day numbers 1-31 + Checkboxes | 4px right margin | Fixed width |
| N Habit Columns | Rotated -90° | Checkboxes only | 4px right margin each | Fixed width each |
| Last Habit | Rotated -90° | Checkboxes only | 8px right margin | Fixed width |
| Reflection | Horizontal | Single-line text with ellipsis | flex-grow: 1 | Flexible width |

## Implementation Notes

### Header Structure
- **Phase 2**: Simple "September 2025" centered header
- **Future**: Full cover art section with decorative elements

### Grid Layout
- Days 1-30 (or 1-31 depending on month) in first column
- 5 habit columns with rotated headers
- Reflection column fills remaining space
- Each row represents one day

### Habit Headers (Rotated -90°)
For September 2025, the 5 habit headers will be:
1. Run 1 mile
2. 20 pushups  
3. Stretch
4. Track all food
5. Bed by 10

### Spacing System
- **2px**: Between checkboxes
- **4px**: Between habit columns
- **8px**: Gap before reflection column
- **12px**: Number to checkbox margin
- **24px**: Checkbox size and grid spacing

### Typography
- **Day numbers**: 11px Courier New, opacity 0.75
- **Habit headers**: 16px Courier New, rotated -90°
- **Reflections**: 12px Courier New, single line with ellipsis

### Interactive Elements
- Each checkbox uses existing Stimulus controller
- Random box styles (0-9) and X styles (0-9)
- Turbo form submission for state persistence
- No page refresh on checkbox toggle