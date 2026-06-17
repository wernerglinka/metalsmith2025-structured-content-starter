# Page Shell

The page shell is the frame every page shares: the document head, header, footer, navigation, branding, and breadcrumbs. In this starter the shell is **not** part of the component catalog. It lives in the site scaffold you own and edit directly:

- Templates: `lib/layouts/pages/parts/` (`head.njk`, `header.njk`, `footer.njk`, `navigation.njk`, `branding.njk`, `breadcrumbs.njk`, and the optional switchers)
- Styles: `lib/assets/styles/` (`_header.css`, `_footer.css`, `_navigation.css`, `_branding.css`, `_breadcrumbs.css`, and the optional switcher styles)
- Scripts: imported by `lib/assets/main.js`

The component catalog under `lib/layouts/components/` is reserved for the authorable sections and partials that make up page content. Chrome is the frame around that content, so it sits in `pages/parts/` instead. Editing the header or footer means editing the file in `pages/parts/` directly; there is no install step and nothing to keep in sync with an upstream catalog.

## Always-on chrome

`head`, `header`, `footer`, `navigation`, and `branding` are always present. Their CSS is pulled into the base bundle through `lib/assets/main.css`, and the header and navigation scripts are imported by `lib/assets/main.js`. Edit those files to change the frame.

## Optional features

Three pieces of chrome are optional and managed by `npm run init` (the `scripts/init-starter.mjs` script):

- **theme-switcher**: a dark/light toggle (off by default). See [docs/theme-switcher.md](theme-switcher.md).
- **language-switcher**: a language dropdown (off by default). See [docs/language-switcher.md](language-switcher.md).
- **breadcrumbs**: on by default; turn it off for small sites that do not need it.

Each optional feature keeps its files in `pages/parts/` and `lib/assets/styles/` but stays inert until wired in, so a site that does not use a feature ships none of its CSS or JS.

### Toggling features

Run the interactive setup and answer y/n for each feature:

```shell
npm run init
```

Or change features non-interactively:

```shell
node scripts/init-starter.mjs status
node scripts/init-starter.mjs enable theme-switcher
node scripts/init-starter.mjs disable breadcrumbs
```

`enable` inserts the feature's import, markup, CSS `@import`, and JS import after fixed anchors in `header.njk` (or `default.njk` for breadcrumbs), `main.css`, and `main.js`. Each inserted line is tagged with a `feature:<name>` comment so `disable` can remove it again. Enabling is idempotent, so it is safe to run twice.

The feature registry is `scripts/features.json`. Adding an entry there makes a new shell feature toggleable without changing the script. Do not hand-edit the tagged lines; use the script so enable and disable stay symmetrical.
