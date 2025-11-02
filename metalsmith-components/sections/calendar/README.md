# Calendar Section

**Version:** 0.0.1
**Content Hash:** 760d96f454a12a25

## Dependencies

This section requires the following partials:

- [text](../partials/text-v0.0.1.zip)
- [commons](../partials/commons-v0.0.1.zip)

**Note:** Dependencies are not included in this package. Download them separately.

## Features

- Includes custom styles
- Includes interactive JavaScript
- Supports multiple providers
  - google-calendar

## Installation

### Automated Installation

```bash
./install.sh
```

The install script will:
- Detect your Metalsmith project
- Read paths from `metalsmith-components.config.json` (if present)
- Check for existing versions
- Verify dependencies
- Copy files to the correct locations

**Note:** Component paths can be customized via `metalsmith-components.config.json` in your project root. See the bundle README for details.

### Manual Installation

Copy the component files to your Metalsmith project:

```bash
cp calendar.njk your-project/lib/layouts/components/sections/calendar/
cp calendar.css your-project/lib/layouts/components/sections/calendar/
cp calendar.js your-project/lib/layouts/components/sections/calendar/
cp manifest.json your-project/lib/layouts/components/sections/calendar/
```

## Usage

Add the calendar section to your page frontmatter:

### Basic Example

Minimal calendar configuration

```yaml
sections:
  - sectionType: calendar
    text:
      title: Example Title
      prose: Example content
```

## More Information

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/library/calendar/

