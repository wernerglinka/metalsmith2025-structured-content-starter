# Cards-list Section

**Version:** 0.0.1
**Content Hash:** 5ceae028f6cbd0fa

## Dependencies

This section requires the following partials:

- [text](../partials/text-v0.0.1.zip)
- [manual-card](../partials/manual-card-v0.0.1.zip)

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
cp cards-list.njk your-project/lib/layouts/components/sections/cards-list/
cp cards-list.css your-project/lib/layouts/components/sections/cards-list/
cp manifest.json your-project/lib/layouts/components/sections/cards-list/
```

## Usage

Add the cards-list section to your page frontmatter:

### Basic Example

Minimal cards-list configuration

```yaml
sections:
  - sectionType: cards-list
    text:
      title: Example Title
      prose: Example content
```

## More Information

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/library/cards-list/

