# Hero Section

**Version:** 0.0.1
**Content Hash:** 5a40eea18a48e4f8

## Dependencies

This section requires the following partials:

- [ctas](../partials/ctas-v0.0.1.zip)
- [text](../partials/text-v0.0.1.zip)
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
cp hero.njk your-project/lib/layouts/components/sections/hero/
cp hero.css your-project/lib/layouts/components/sections/hero/
cp manifest.json your-project/lib/layouts/components/sections/hero/
```

## Usage

Add the hero section to your page frontmatter:

### Basic Example

Minimal hero configuration

```yaml
sections:
  - sectionType: hero
    text:
      title: Example Title
      prose: Example content
```

## More Information

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/library/hero/

