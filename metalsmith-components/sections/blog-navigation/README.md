# Blog-navigation Section

**Version:** 0.0.1
**Content Hash:** 08795c07234829ee

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
cp blog-navigation.njk your-project/lib/layouts/components/sections/blog-navigation/
cp blog-navigation.css your-project/lib/layouts/components/sections/blog-navigation/
cp manifest.json your-project/lib/layouts/components/sections/blog-navigation/
```

## Usage

Add the blog-navigation section to your page frontmatter:

### Basic Example

Minimal blog-navigation configuration

```yaml
sections:
  - sectionType: blog-navigation
    text:
      title: Example Title
      prose: Example content
```

## More Information

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/library/blog-navigation/

