# disclosure

Named for the spec term: details/summary form a "disclosure widget".
The name "accordion" is deliberately avoided because this library
ships an accordion *section*, and the component bundler keeps partials
and sections in one namespace, failing the build on duplicate names.

Renders a list of collapsed disclosure blocks with the native
`<details>`/`<summary>` elements: accessible, keyboard-operable, and
JS-free. Each item's body is markdown, rendered through `mdToHTML`.

The expand/collapse animates in browsers that support
`::details-content` with `interpolate-size`; everywhere else the
blocks simply snap open, which was the pre-animation behavior.

## When to use which

- **accordion section**: a standalone FAQ-style page section with
  JS-driven behavior, ARIA state, and one-open-at-a-time control.
- **disclosure partial**: the zero-JS primitive for folding secondary
  content (policies, boilerplate, fine print) into another section's
  text column.

## Usage

```njk
{% from "components/_partials/disclosure/disclosure.njk" import disclosures %}

{{ disclosures([
  { title: 'Accessibility', prose: 'Markdown body with [links](/x).' },
  { title: 'Cancellation policy', prose: 'More markdown.' }
]) }}
```

In the multi-media section, an optional `disclosures` array on the
section renders beneath the text column's prose and CTAs:

```yaml
- sectionType: multi-media
  mediaType: iframe
  iframe:
    src: 'https://example.com/registration'
    title: 'Registration form'
  text:
    title: 'What to expect'
    prose: 'Class description...'
  disclosures:
    - title: 'Accessibility'
      prose: 'The studio is wheelchair accessible...'
    - title: 'Cancellation policy'
      prose: 'Full refund up to 7 days before...'
```
