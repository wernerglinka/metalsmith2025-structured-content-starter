# Audio Partial

**Version:** 0.0.1
**Content Hash:** 110aa8502fa63012

## Dependencies

This partial requires the following partials:

- [image](../partials/image-v0.0.1.zip)
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
cp audio.njk your-project/lib/layouts/components/_partials/audio/
cp audio.css your-project/lib/layouts/components/_partials/audio/
cp audio.js your-project/lib/layouts/components/_partials/audio/
cp manifest.json your-project/lib/layouts/components/_partials/audio/
```

## More Information

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/references/partials/audio/

