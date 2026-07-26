# Dark/Light Theme Switcher

An optional header button that toggles the site between light and dark themes. The choice is saved to `localStorage` and re-applied on the next visit. It is off by default.

## Enable it

```shell
node scripts/init-starter.mjs enable theme-switcher
```

This wires the switcher into the shell: the macro import and call in `lib/layouts/pages/parts/header.njk`, the styles in `lib/assets/main.css`, and the script in `lib/assets/main.js`. To turn it off again:

```shell
node scripts/init-starter.mjs disable theme-switcher
```

## How it works

The button (`lib/layouts/pages/parts/dark-light-theme-switcher.njk`) shows a moon/sun icon. Its script (`dark-light-theme-switcher.js`) is self-contained: on load it reads the saved theme and applies it, and on click it toggles a `dark-theme` class on `<body>` and stores the choice. The icons used (`moon`, `sun`) are already in `lib/layouts/icons/`.

## Make it theme your design

The toggle flips a `dark-theme` class on `<body>`, and `lib/assets/styles/_design-tokens.css` ships a complete `body.dark-theme` block that redefines the color tokens under it. Because the shell and the components consume tokens rather than raw colors, enabling the switcher themes the whole page out of the box.

When you retune the light tokens to your own design, retune the `body.dark-theme` block alongside them; the two live next to each other in the same file. Tokens documented as theme-constant (the button colors, the image screens, `--color-footer-text-light`) are deliberately absent from the dark block and keep their light values.
