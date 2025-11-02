# Commons Section

**Version:** 0.0.1
**Content Hash:** e41f3eca65589cb9

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
cp commons.njk your-project/lib/layouts/components/sections/commons/
cp commons.css your-project/lib/layouts/components/sections/commons/
cp manifest.json your-project/lib/layouts/components/sections/commons/
```

## Usage

Add the commons section to your page frontmatter:

### Basic Example

Minimal commons configuration

```yaml
sections:
  - sectionType: commons
    text:
      title: Example Title
      prose: Example content
```

## More Information

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/library/commons/

