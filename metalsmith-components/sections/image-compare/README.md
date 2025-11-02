# Image-compare Section

**Version:** 0.0.1
**Content Hash:** cc61e2d3710544d8

## Dependencies

This section requires the following partials:

- [image](../partials/image-v0.0.1.zip)
- [icon](../partials/icon-v0.0.1.zip)
- [commons](../partials/commons-v0.0.1.zip)

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
cp image-compare.njk your-project/lib/layouts/components/sections/image-compare/
cp image-compare.css your-project/lib/layouts/components/sections/image-compare/
cp image-compare.js your-project/lib/layouts/components/sections/image-compare/
cp manifest.json your-project/lib/layouts/components/sections/image-compare/
```

## Usage

Add the image-compare section to your page frontmatter:

### Basic Example

Minimal image-compare configuration

```yaml
sections:
  - sectionType: image-compare
    text:
      title: Example Title
      prose: Example content
```

## More Information

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/library/image-compare/

