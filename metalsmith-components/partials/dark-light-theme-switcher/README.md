# Dark-light-theme-switcher Partial

**Version:** 0.0.1
**Content Hash:** 7cb96caf563b3b18

## Dependencies

This partial requires the following partials:

- [icon](../partials/icon-v0.0.1.zip)

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
cp dark-light-theme-switcher.njk your-project/lib/layouts/components/_partials/dark-light-theme-switcher/
cp dark-light-theme-switcher.css your-project/lib/layouts/components/_partials/dark-light-theme-switcher/
cp dark-light-theme-switcher.js your-project/lib/layouts/components/_partials/dark-light-theme-switcher/
cp manifest.json your-project/lib/layouts/components/_partials/dark-light-theme-switcher/
```

## More Information

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/references/partials/dark-light-theme-switcher/

