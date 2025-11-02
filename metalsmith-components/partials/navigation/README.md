# Navigation Partial

**Version:** 0.0.1
**Content Hash:** a707c02e967b26ec

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
cp navigation.njk your-project/lib/layouts/components/_partials/navigation/
cp navigation.css your-project/lib/layouts/components/_partials/navigation/
cp navigation.js your-project/lib/layouts/components/_partials/navigation/
cp manifest.json your-project/lib/layouts/components/_partials/navigation/
```

## More Information

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/references/partials/navigation/

