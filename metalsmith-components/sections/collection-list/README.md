# Collection-list Section

**Version:** 0.0.1
**Content Hash:** 8acc0e08f161e7cd

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
cp collection-list.njk your-project/lib/layouts/components/sections/collection-list/
cp collection-list.css your-project/lib/layouts/components/sections/collection-list/
cp manifest.json your-project/lib/layouts/components/sections/collection-list/
```

## Usage

Add the collection-list section to your page frontmatter:

### Basic Example

Minimal collection-list configuration

```yaml
sections:
  - sectionType: collection-list
    text:
      title: Example Title
      prose: Example content
```

## More Information

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/library/collection-list/

