# Author-date Partial

**Version:** 0.0.1
**Content Hash:** 31a6b688afc25f68

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
cp author-date.njk your-project/lib/layouts/components/_partials/author-date/
cp author-date.css your-project/lib/layouts/components/_partials/author-date/
cp manifest.json your-project/lib/layouts/components/_partials/author-date/
```

## More Information

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/references/partials/author-date/

