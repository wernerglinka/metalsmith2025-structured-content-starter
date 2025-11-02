# Header Section

**Version:** 0.0.1
**Content Hash:** 5979a1c0383bb580

## Dependencies

This section requires the following partials:

- [branding](../partials/branding-v0.0.1.zip)
- [navigation](../partials/navigation-v0.0.1.zip)

**Note:** Dependencies are not included in this package. Download them separately.

## Features

- Includes custom styles
- Includes interactive JavaScript

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
cp header.njk your-project/lib/layouts/components/sections/header/
cp header.css your-project/lib/layouts/components/sections/header/
cp header.js your-project/lib/layouts/components/sections/header/
cp manifest.json your-project/lib/layouts/components/sections/header/
```

## Usage

Add the header section to your page frontmatter:

### Basic Example

Minimal header configuration

```yaml
sections:
  - sectionType: header
    text:
      title: Example Title
      prose: Example content
```

## More Information

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/library/header/

