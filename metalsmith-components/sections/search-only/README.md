# Search-only Section

**Version:** 0.0.1
**Content Hash:** 639c399544deb194

## Dependencies

This section requires the following partials:

- [search](../partials/search-v0.0.1.zip)
- [text](../partials/text-v0.0.1.zip)
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
cp search-only.njk your-project/lib/layouts/components/sections/search-only/
cp search-only.css your-project/lib/layouts/components/sections/search-only/
cp search-only.js your-project/lib/layouts/components/sections/search-only/
cp manifest.json your-project/lib/layouts/components/sections/search-only/
```

## Usage

Add the search-only section to your page frontmatter:

### Basic Example

Minimal search-only configuration

```yaml
sections:
  - sectionType: search-only
    text:
      title: Example Title
      prose: Example content
```

## More Information

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/library/search-only/

