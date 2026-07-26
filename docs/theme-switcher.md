# Dark/Light Theme Switcher

An optional header button that toggles the site between light and dark themes. The choice is saved to `localStorage` and re-applied on the next visit; before a visitor has chosen, the system preference (`prefers-color-scheme`) decides. It is off by default.

## Enable it

```shell
node scripts/init-starter.mjs enable theme-switcher
```

This wires the switcher into the shell: the macro import and call in `lib/layouts/pages/parts/header.njk`, the styles in `lib/assets/main.css`, the script in `lib/assets/main.js`, and a first-paint init include in `lib/layouts/pages/default.njk`. To turn it off again:

```shell
node scripts/init-starter.mjs disable theme-switcher
```

## How it works

The button (`lib/layouts/pages/parts/dark-light-theme-switcher.njk`) shows a moon/sun icon. Its script (`dark-light-theme-switcher.js`) is self-contained: on load it applies the saved theme (or the system preference when nothing is saved), and on click it toggles a `dark-theme` class on `<body>` and stores the choice. The icons used (`moon`, `sun`) are already in `lib/layouts/icons/`.

Because `main.js` loads at the end of the page, a tiny inline script (`lib/layouts/pages/parts/theme-init.njk`, included right after `<body>` opens) applies the same rules synchronously, so a returning dark-theme visitor never sees a flash of the light theme. Both scripts share one decision: saved choice first, system preference otherwise.

## Make it theme your design

The toggle flips a `dark-theme` class on `<body>`, and `lib/assets/styles/_design-tokens.css` ships a complete `body.dark-theme` block that redefines the color tokens under it. Because the shell and the components consume tokens rather than raw colors, enabling the switcher themes the whole page out of the box.

When you retune the light tokens to your own design, retune the `body.dark-theme` block alongside them; the two live next to each other in the same file. Tokens documented as theme-constant (the button colors, the image screens, `--color-footer-text-light`) are deliberately absent from the dark block and keep their light values.
