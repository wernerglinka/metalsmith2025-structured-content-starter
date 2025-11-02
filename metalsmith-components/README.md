# Metalsmith Components Bundle v0.0.1

Complete collection of Metalsmith components for building modern websites.

## Contents

This bundle includes:

- **31 Section Components:** audio-only, banner, blog-author, blog-navigation, blurbs, calendar, cards-list, code, collection-list, columns, commons, compound, flip-cards, footer, header, hero, hero-slider, icon-only, image-compare, image-only, logos-list, lottie-only, maps, multi-media, podcast, search-only, simple-accordion, slider, testimonial, text-only, video-only
- **21 Partial Components:** audio, author-date, branding, breadcrumbs, button, collection-card, collection-pagination, ctas, dark-light-theme-switcher, flip-card, icon, image, lottie, manual-card, navigation, overlay, search, slider-pagination, text, text-link, video

## Configuration

### Customizing Component Paths

By default, components install to:
- Sections: `lib/layouts/components/sections/`
- Partials: `lib/layouts/components/_partials/`

To customize these paths, create a `metalsmith-components.config.json` file in your project root:

```json
{
  "componentsBasePath": "lib/layouts/components",
  "sectionsDir": "sections",
  "partialsDir": "_partials"
}
```

Edit these values to match your project structure. If this file is not present, the defaults shown above will be used.

## Installation

### Installation Modes

The bundle installer supports two modes:

**1. Full Install (default)** - Installs all components:
```bash
# From your project root:
unzip metalsmith-components.zip
./metalsmith-components/install-all.sh
```

If you already have components installed, the script will prompt you to choose between:
- Install all components (adds new ones, updates existing)
- Update existing components only (skips new components)

**2. Update Mode** - Only updates components you already have:
```bash
./metalsmith-components/install-all.sh --update-only
# or use the short form:
./metalsmith-components/install-all.sh -u
```

This is perfect for:
- Updating a subset of components you're already using
- Getting bug fixes and improvements without adding new components
- Keeping your project lean with only the components you need

### Selective Installation

To install individual components from the bundle:

```bash
# From your project root:
./metalsmith-components/sections/hero/install.sh
# or for partials:
./metalsmith-components/partials/text/install.sh
```

## Documentation

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/

## License

MIT License
