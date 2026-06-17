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

Enabling the switcher gives you the toggle and the dark styling for the chrome, but the toggle only flips a `dark-theme` class on `<body>`. For the whole page to respond, define dark overrides for your design tokens under `.dark-theme` in `lib/assets/styles/_design-tokens.css` (or a dedicated dark-theme stylesheet). For example:

```css
.dark-theme {
  --color-background: #14171a;
  --color-text: #e6e6e6;
  /* ...override the rest of your semantic color tokens... */
}
```

Without these overrides the button works and persists, but only the components that already ship dark styles will change.
