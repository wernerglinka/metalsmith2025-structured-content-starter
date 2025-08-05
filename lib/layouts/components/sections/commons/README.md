# Commons Section Component

The commons section provides the foundational CSS wrapper system for all sections in the application. It contains no template (empty .njk file) but provides essential base styles and utilities that all other sections inherit.

## Purpose

- **Universal Section Wrapper**: Provides `.section-wrapper` base class for all sections
- **Consistent Spacing**: Manages margins, padding, and spacing across all sections
- **Responsive Layout**: Implements fluid design patterns for content containers
- **Background System**: Handles background images and overlay screens

## Key Features

### Section Wrapper System
- **Base Class**: `.section-wrapper` applied to all sections
- **Flexible Spacing**: Configurable margins and padding via CSS custom properties
- **Container Support**: Optional `.in-container` for max-width constraints
- **Full-Screen Mode**: Support for viewport-height sections

### Responsive Content Layout
- **Switcher Pattern**: Inspired by Every Layout's switcher for responsive columns
- **Configurable Threshold**: Default 60rem breakpoint, customizable per section
- **Flexible Growth**: Content areas grow and shrink based on available space
- **Reverse Support**: `.is-reverse` for RTL content flow

### Background Image System
- **Absolute Positioning**: Background images positioned behind content
- **Overlay Screens**: Light and dark overlays for better text readability
- **Configurable Positioning**: Bottom-aligned by default, customizable

### Utility Classes

```css
/* Screen reader only content */
.sr-only

/* Skip link for keyboard navigation */
.skip-link

/* Center alignment utility */
.align-center
```

## CSS Architecture

### Section Wrapper Classes
```css
.section-wrapper              /* Base wrapper for all sections */
.section-wrapper.in-container /* Constrained width sections */
.section-wrapper.is-dark      /* Dark theme sections */
.section-wrapper.full-screen  /* Viewport height sections */
.section-wrapper.no-top-margin    /* Remove top margin */
.section-wrapper.no-bottom-margin /* Remove bottom margin */
.section-wrapper.no-top-padding   /* Remove top padding */
.section-wrapper.no-bottom-padding /* Remove bottom padding */
```

### Background Classes
```css
.background-image           /* Background image container */
.has-light-screen         /* Light overlay on background */
.has-dark-screen          /* Dark overlay on background */
```

### Content Layout Classes
```css
.content                   /* Responsive content container */
.content.is-reverse       /* Reversed content flow */
.prose                    /* Text content with optimal width */
```

## Configuration

### CSS Custom Properties
```css
--section-space: var(--space-l-2xl)    /* Section margins */
--section-padding: var(--space-s-l)    /* Section padding */
--wrapper-max-width: 85rem             /* Container max width */
--threshold: 60rem                     /* Content layout breakpoint */
--content-gap: 2rem                    /* Gap between content areas */
```

### Section Configuration
Sections are configured through the `containerFields` object:

```yaml
containerFields:
  inContainer: true          # Adds .in-container class
  isAnimated: true          # Adds .is-animated class
  noMargin:
    top: true               # Adds .no-top-margin class
    bottom: false           # Controls bottom margin
  noPadding:
    top: false              # Controls top padding
    bottom: true            # Adds .no-bottom-padding class
  background:
    isDark: true            # Adds .is-dark class
    color: "#f0f0f0"        # Sets background-color style
    image: "/bg.jpg"        # Adds .background-image element
    imageScreen: "light"    # Adds .has-light-screen class
```

## Integration

### Build System Integration
The commons component is:
- **Dependency**: Listed as dependency in all section manifests
- **Load Order**: Loaded first in the component bundling system
- **Universal**: Styles applied to every section automatically

### Template Integration
Applied automatically through the section rendering system:
```html
<section class="section-wrapper [additional-classes]">
  <!-- Background image if configured -->
  <div class="background-image" style="background-image: url(...)"></div>
  
  <!-- Section content -->
  <div class="content">
    <!-- Individual section template content -->
  </div>
</section>
```

## Usage Examples

### Basic Section
```yaml
containerFields:
  inContainer: true
  background:
    isDark: false
```

### Full-Screen Hero
```yaml
isFullScreen: true
containerFields:
  background:
    image: "/hero-bg.jpg"
    imageScreen: "light"
```

### Dark Section with Custom Spacing
```yaml
containerFields:
  background:
    isDark: true
    color: "#1a1a1a"
  noMargin:
    bottom: true
```

## Best Practices

1. **Consistent Spacing**: Use the provided spacing system rather than custom margins
2. **Responsive Design**: Use the content layout system for responsive behavior
4. **Performance**: Minimize custom CSS by using the provided utilities
5. **Maintainability**: Follow the established class naming conventions

The commons section ensures all sections have a consistent, accessible, and responsive foundation while allowing for extensive customization through the configuration system.
