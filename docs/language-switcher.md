# Language Switcher

An optional header dropdown for multi-language sites. It lists the available languages and navigates to the localized version of the current page. It is off by default, and it needs a small data file before it will show anything useful.

## Enable it

```shell
node scripts/init-starter.mjs enable language-switcher
```

This wires the switcher into the shell: the macro import and call in `lib/layouts/pages/parts/header.njk`, the styles in `lib/assets/main.css`, and the script in `lib/assets/main.js`. To turn it off again:

```shell
node scripts/init-starter.mjs disable language-switcher
```

## Provide the language data

The switcher reads `data.languages`, so create `lib/data/languages.json`:

```json
{
  "available": [
    { "code": "en", "label": "English" },
    { "code": "de", "label": "Deutsch" }
  ],
  "defaultLang": "en",
  "fallbackUrl": "/404/"
}
```

`available` is the list shown in the dropdown, `defaultLang` is the code shown as current, and `fallbackUrl` is where the switcher sends a visitor when a localized page does not exist. The button uses the `globe` icon, which is already in `lib/layouts/icons/`.

## Beyond the switcher

The switcher is only the navigation control. A full multi-language setup also needs localized content and a URL scheme for each language, which is a larger topic than this widget. Add the language data and the switcher first, then build out localized pages to match the `code` values you listed.
