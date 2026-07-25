# Iframe Partial Component

A responsive wrapper for an embedded third-party frame, such as a
registration form, a map, or any page designed for embedding. The
iframe fills the available width; the embedded page's own layout is
responsive inside it.

## Data Structure

```yaml
iframe:
  src: 'https://example.com/embed'
  title: 'Accessible frame title'
  allow: '' # optional permissions policy, e.g. 'payment'
```

## Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `src` | String | Yes | The embed URL |
| `title` | String | Yes | Accessible title for the frame |
| `allow` | String | No | Permissions policy for the frame (e.g. `payment` for donation/checkout embeds) |

## HTML Output

```html
<div class="iframe-frame">
  <iframe src="https://example.com/embed" title="Accessible frame title" loading="lazy"></iframe>
</div>
```

## Styling

The frame renders at a fixed default height of `50rem`, which suits
tall embeds like registration forms and avoids double scrollbars.
Contexts can override it via the `--iframe-height` custom property:

```css
.my-section .iframe-frame {
  --iframe-height: 30rem;
}
```

## Notes

- The iframe loads lazily (`loading="lazy"`), so offscreen embeds do
  not block page load.
- Only set `allow` when the embed needs it; `payment` is required by
  checkout and donation forms such as Givebutter.
