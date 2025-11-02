# Icon-only Section

**Version:** 0.0.1
**Content Hash:** 4e909040f2318259

## Dependencies

This section requires the following partials:

- [ctas](../partials/ctas-v0.0.1.zip)
- [icon](../partials/icon-v0.0.1.zip)
- [commons](../partials/commons-v0.0.1.zip)

**Note:** Dependencies are not included in this package. Download them separately.

## Features

- Includes custom styles

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
cp icon-only.njk your-project/lib/layouts/components/sections/icon-only/
cp icon-only.css your-project/lib/layouts/components/sections/icon-only/
cp manifest.json your-project/lib/layouts/components/sections/icon-only/
```

## Usage

Add the icon-only section to your page frontmatter:

### Basic Example

Minimal icon-only configuration

```yaml
sections:
  - sectionType: icon-only
    text:
      title: Example Title
      prose: Example content
```

## More Information

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/library/icon-only/

