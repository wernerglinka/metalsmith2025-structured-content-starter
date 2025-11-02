# Image-only Section

**Version:** 0.0.1
**Content Hash:** e9faf2b7004b6b21

## Dependencies

This section requires the following partials:

- [ctas](../partials/ctas-v0.0.1.zip)
- [image](../partials/image-v0.0.1.zip)
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
cp image-only.njk your-project/lib/layouts/components/sections/image-only/
cp image-only.css your-project/lib/layouts/components/sections/image-only/
cp manifest.json your-project/lib/layouts/components/sections/image-only/
```

## Usage

Add the image-only section to your page frontmatter:

### Basic Example

Minimal image-only configuration

```yaml
sections:
  - sectionType: image-only
    text:
      title: Example Title
      prose: Example content
```

## More Information

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/library/image-only/

