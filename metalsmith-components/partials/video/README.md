# Video Partial

**Version:** 0.0.1
**Content Hash:** 7b6d99f183ef4238

## Dependencies

This partial requires the following partials:

- [overlay](../partials/overlay-v0.0.1.zip)
- [image](../partials/image-v0.0.1.zip)
- [icon](../partials/icon-v0.0.1.zip)

**Note:** Dependencies are not included in this package. Download them separately.

## Features

- Includes custom styles
- Includes interactive JavaScript
- Supports multiple providers
  - cloudinary, vimeo, youtube

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
cp video.njk your-project/lib/layouts/components/_partials/video/
cp video.css your-project/lib/layouts/components/_partials/video/
cp video.js your-project/lib/layouts/components/_partials/video/
cp manifest.json your-project/lib/layouts/components/_partials/video/
```

## More Information

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/references/partials/video/

