# Compound Section

**Version:** 0.0.1
**Content Hash:** c5bcd96cf73a176a

## Dependencies

This section requires the following partials:

- [commons](../partials/commons-v0.0.1.zip)
- [text](../partials/text-v0.0.1.zip)
- [ctas](../partials/ctas-v0.0.1.zip)

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
cp compound.njk your-project/lib/layouts/components/sections/compound/
cp compound.css your-project/lib/layouts/components/sections/compound/
cp compound.js your-project/lib/layouts/components/sections/compound/
cp manifest.json your-project/lib/layouts/components/sections/compound/
```

## Usage

Add the compound section to your page frontmatter:

### Basic Example

Minimal compound configuration

```yaml
sections:
  - sectionType: compound
    text:
      title: Example Title
      prose: Example content
```

## More Information

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/library/compound/

