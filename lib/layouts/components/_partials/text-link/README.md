# Text Link Partial

Renders a styled text link. Typically used within the `ctas` partial for non-button CTAs.

## Features

- Styled text link with consistent appearance
- Automatic external link detection (adds `target="_blank"` and security attributes)
- Accessible labels for external links

## Usage

Import the macro in your template:

```njk
{% from "components/_partials/text-link/text-link.njk" import textLink %}

{{ textLink({
  url: "/path",
  label: "Learn More"
}) }}
```

## Parameters

- `url` (required): Link destination
- `label` (required): Link text

## External Links

External links automatically receive security attributes (`target="_blank" rel="noopener noreferrer"`) and an accessible label indicating they open in a new window.

## Why No `fields` Block

Like `button`, this partial renders a single CTA entry whose authorable
shape (`url`, `label`) is declared by the `ctas` partial's `fields` block.
It is the renderer of that entry, not a separately authored component, so
it declares no `fields` of its own.
