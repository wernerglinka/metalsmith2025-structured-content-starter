# Multi-media Section

**Version:** 0.0.1
**Content Hash:** c8a7e87dbeec42f3

## Dependencies

This section requires the following partials:

- [ctas](../partials/ctas-v0.0.1.zip)
- [text](../partials/text-v0.0.1.zip)
- [image](../partials/image-v0.0.1.zip)
- [video](../partials/video-v0.0.1.zip)
- [audio](../partials/audio-v0.0.1.zip)
- [icon](../partials/icon-v0.0.1.zip)
- [lottie](../partials/lottie-v0.0.1.zip)
- [commons](../partials/commons-v0.0.1.zip)

**Note:** Dependencies are not included in this package. Download them separately.

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
cp multi-media.njk your-project/lib/layouts/components/sections/multi-media/
cp multi-media.css your-project/lib/layouts/components/sections/multi-media/
cp manifest.json your-project/lib/layouts/components/sections/multi-media/
```

## Usage

Add the multi-media section to your page frontmatter:

### Basic Example

Minimal multi-media configuration

```yaml
sections:
  - sectionType: multi-media
    text:
      title: Example Title
      prose: Example content
```

## More Information

For complete documentation and live examples, visit:
https://metalsmith-components.netlify.app/library/multi-media/

