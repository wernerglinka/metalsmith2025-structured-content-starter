# Banner Section Component

A versatile banner component designed for prominent in-page banners, call-to-action sections, and promotional content. Perfect for highlighting important messages, CTAs, or featured content within page layouts.

## Features

- **Flexible Layout**: Supports text-only, image-only, or combined layouts
- **Background Images**: Configurable background images with optional screen overlays
- **CTA Banner Mode**: Special centered layout for call-to-action banners
- **Reverse Layout**: Optional reverse layout for content positioning
- **Responsive Design**: Fluid layout that adapts to viewport size
- **Content Flexibility**: All text elements and CTAs are optional

## Data Structure

```yaml
- sectionType: banner
  containerTag: aside  # or section, div
  disabled: false
  id: "section-id"
  classes: "cta-banner"  # Optional: adds centered CTA styling
  containerFields:
    inContainer: false
    isAnimated: true
    noMargin:
      top: false
      bottom: false
    noPadding:
      top: false
      bottom: false
    background:
      isDark: false
      color: ""
      image: "/assets/images/banner-bg.jpg"
      imageScreen: "light"  # light, dark, none
  reverse: false  # Reverses content positioning
  text:
    leadIn: "Special Offer"
    title: "Banner Title"
    titleTag: "h2"
    subTitle: "Compelling subtitle"
    prose: |-
      Banner description text that can span
      multiple paragraphs in Markdown format.
  ctas:
    - url: "/get-started"
      label: "Get Started"
      isButton: true
      buttonStyle: "primary"
    - url: "/learn-more"
      label: "Learn More"
      isButton: false
  image:
    src: "/assets/images/banner-image.jpg"
    alt: "Banner image description"
    caption: ""
```

## HTML Structure

```html
<div class="container banner content is-reverse">
  
  <!-- Optional Banner Image -->
  <div class="image">
    <img src="banner.jpg" alt="Description">
  </div>
  
  <!-- Text Content and CTAs -->
  <div class="text flow">
    <div class="prose flow">
      <p class="lead-in">Special Offer</p>
      <h2>Banner Title</h2>
      <p class="sub-title">Compelling subtitle</p>
      <div class="prose">Banner description...</div>
    </div>
    
    <div class="ctas flow">
      <a class="cta button primary" href="/get-started">Get Started</a>
      <a class="cta link" href="/learn-more">Learn More</a>
    </div>
  </div>
  
</div>
```

## CSS Architecture

### Layout Variations
- **Standard**: Default banner layout with flexible content positioning
- **Reverse**: Content positioned to the right (via `is-reverse` class)
- **CTA Banner**: Centered layout with constrained width (via `cta-banner` class)

### CTA Banner Mode
When using the `cta-banner` class:
- Maximum width of 60rem
- Centered alignment
- Text-centered layout
- Optimized for call-to-action content

### Responsive Behavior
- Uses fluid design principles for optimal content display
- Custom threshold of 60rem for content container breakpoint
- Inherits responsive behavior from the commons section system

## Usage Patterns

### Standard In-Page Banner
```yaml
- sectionType: banner
  containerTag: section
  classes: ""
  text:
    title: "Featured Content"
    prose: "Important announcement or featured information"
  ctas:
    - url: "/details"
      label: "Learn More"
      isButton: true
```

### CTA Banner
```yaml
- sectionType: banner
  containerTag: aside
  classes: "cta-banner"
  containerFields:
    background:
      image: "/assets/images/cta-bg.jpg"
      imageScreen: "light"
  text:
    leadIn: "Limited Time"
    title: "Special Offer"
    prose: "Don't miss out on this exclusive opportunity"
  ctas:
    - url: "/signup"
      label: "Sign Up Now"
      isButton: true
      buttonStyle: "primary"
```

### Image + Text Banner
```yaml
- sectionType: banner
  reverse: true
  text:
    title: "Product Feature"
    prose: "Highlight key product benefits"
  image:
    src: "/assets/images/product.jpg"
    alt: "Product showcase"
  ctas:
    - url: "/product"
      label: "View Product"
      isButton: true
```

## Dependencies

- `ctas`: For rendering call-to-action buttons and links
- `text`: For rendering text content (lead-in, title, subtitle, prose)
- `image`: For rendering responsive images
- `commons`: For shared utilities and base styles

## Customization

### Custom Classes
Add custom styling through the classes field:
```yaml
classes: "cta-banner custom-banner special-promotion"
```

### Styling Hooks
Key CSS classes for customization:
- `.banner`: Main container
- `.banner.is-reverse`: Reversed layout
- `.cta-banner .content`: CTA banner specific styling
- `.text`: Text content container
- `.image`: Image container

## Accessibility

- Uses semantic HTML elements (`aside`, `section`)
- Proper heading hierarchy with configurable `titleTag`
- Alt text support for images
- Screen reader friendly CTA structure

## Best Practices

1. **Use appropriate container tags**: `aside` for promotional content, `section` for main content
2. **Optimize images**: Provide appropriate aspect ratios and alt text
3. **Keep CTAs focused**: Limit to 1-2 primary actions per banner
4. **Consider background contrast**: Use `imageScreen` to ensure text readability
5. **Test responsively**: Verify banner appearance across different viewport sizes
