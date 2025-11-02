# Code Section

**Version:** 0.0.1
**Content Hash:** 4a23b03b27e4add8

## Dependencies

This section requires the following partials:

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
cp code.njk your-project/lib/layouts/components/sections/code/
cp code.css your-project/lib/layouts/components/sections/code/
cp code.js your-project/lib/layouts/components/sections/code/
cp manifest.json your-project/lib/layouts/components/sections/code/
```

## Usage

Add the code section to your page frontmatter:

### Basic Example

Minimal code configuration

```yaml
sections:
  - sectionType: code
    text:
      title: Example Title
      prose: Example content
```

## More Information

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/library/code/

