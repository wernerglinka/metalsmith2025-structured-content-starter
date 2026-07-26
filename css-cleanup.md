# CSS cleanup: the token contract between this starter and the library

Working notes written 2026-07-25, to be picked up in a later session. This is
starter-side work. The library has its own list in that repository's
`update.md`, and the two halves are described below so whoever does either one
can see the whole picture.

Nothing here is broken enough to block a site. The items that rendered
incorrectly were fixed in library v1.3.2, see section 2; what remains is the
difference between "works" and "themeable".

---

## Who owns what

Styling a structured site is split three ways, and the split is not obvious
until something falls between the cracks.

**The library owns component CSS.** Every file under
`lib/layouts/components/` arrives from canon and is overwritten on reinstall.
Editing it here is a mistake: `npm run components:status` will report the
component as `modified` and the next install will discard the work.

**This starter owns the vocabulary those components resolve against.** The
design tokens in `lib/assets/styles/_design-tokens.css`, the reset and page
shell in the other `lib/assets/styles/` files, and the layer assignment of
each in `lib/assets/main.css`. A canon component writing
`gap: var(--space-m)` only works because this starter defines `--space-m`.

**The site owns overrides.** `lib/overrides/<name>/<name>.css` in the `site`
layer, and `_theme-customization.css` for decisions that are not about one
component.

So the component design API, the `--<component>-<property>` convention the
library is working towards, is a contract with two signatories. Canon defines
the properties and their fallbacks; the starter guarantees the tokens those
fallbacks name. Canon cannot reference a token this starter does not ship, and
this starter cannot drop a token canon references.

---

## What the audit found

Run against the components installed here, comparing the tokens declared in
`lib/assets/styles/` against every `var(--x)` a component consumes, excluding
each component's own namespaced properties:

- 103 tokens defined by this starter
- 69 global tokens consumed by canon components
- 11 consumed but not defined

Those 11 are three different problems wearing the same shirt.

### 1. Not a token at all (leave alone)

`--single-list-width` is set inline by the `logos-list` template per instance.
It is a component parameter, not part of the vocabulary, and its absence from
the token file is correct.

### 2. Broken references (fixed in library v1.3.2)

Two declarations resolved to nothing and were dropped at computed-value time,
so they silently did not apply:

| Token | Component | Used for |
|---|---|---|
| `--default-letter-spacing` | `button` | `letter-spacing` on every button |
| `--space-lg` | `collection-pagination` | wrapper margin, and icon width/height |

The library fixed both on 2026-07-25 in v1.3.2, and the fix surfaced a larger
count than this audit saw. Because the audit runs against the components
installed here, it could not see canon components this site never installed:
`--space-lg` also appeared in `code` and `search`, `--default-letter-spacing`
also in `podcast`, and `search.css` alone consumed ten further tokens from a
foreign naming scheme (`--color-text-tertiary`, `--space-md`,
`--font-size-sm` and friends). Canon-wide the true count was seventeen
silently dropped declarations across five components, not two.

How they were fixed matters on this side. `--space-lg` became `--space-l` and
the search tokens were mapped into the existing vocabulary, so those ask
nothing new of this starter. But `--default-letter-spacing` became
`--tracking`, which canon now references directly with no fallback, because
`body` already applied it and the change is behaviour-neutral. `--tracking`
has therefore moved from the page shell into the set of tokens canon is
entitled to rely on: renaming or dropping it now breaks `button` and
`podcast`.

Sites pick the fixes up by reinstalling the affected components: `button`,
`collection-pagination`, `code`, `search`, `podcast`.

### 3. Fallback-only values (the actual starter decision)

Eight tokens are consumed with an inline fallback, so components render
correctly, but the fallback is the only value there is. A site cannot retune
them by setting a token, which is precisely what a token is for:

| Token | Fallback | First seen in |
|---|---|---|
| `--content-gap` | `2rem` | `blog-author` |
| `--wrapper-max-width` | `85rem` | `commons` |
| `--logo-animation-speed` | `15s` | `logos-list` |
| `--logo-list-height` | `10rem` | `logos-list` |
| `--iframe-height` | `50rem` | `iframe` |
| `--font-md` | `1.25rem` | `overlay` |
| `--flow-space` | `1em` | `text` |
| `--color-primary-light` | `var(--color-primary)` | `slider-pagination` |

The decision for each is whether it belongs in the published vocabulary.

`--wrapper-max-width` and `--content-gap` are layout-wide and clearly do; a
site that wants a wider measure should say so once. `--font-md` looks like it
belongs in the type scale next to the sizes already defined. `--flow-space` is
already a documented idiom in the stack and probably deserves a real default.
`--color-primary-light` reads as a palette gap rather than a component
concern.

The three `logos-list` and `iframe` values are more likely component
properties than site tokens, which makes them the library's problem: renamed
to `--logos-list-*` and `--iframe-height` scoped to the component, they stop
being vocabulary at all. Deciding that per token is the point of this list.

---

## The work, in order

1. **Decide the vocabulary.** For each of the eight, either define it in
   `_design-tokens.css` with the current fallback as its value, or tell the
   library it should become a component-scoped property. Prefer the second for
   anything only one component uses.
2. **Define what you keep.** Adding a token with the same value the fallback
   already has is behaviour-neutral by construction, which makes this a safe
   change to verify: the built CSS should render identically, and only the
   ability to retune should differ.
3. **Document the vocabulary.** `_design-tokens.css` is a public interface for
   canon components as much as for this site. It should say which token groups
   canon is entitled to rely on.
4. **Make the audit repeatable.** The check above was a one-off script. As
   `scripts/token-contract.mjs` it would catch a canon component referencing a
   token this starter never shipped, which is the failure mode that renders
   subtly wrong and warns nobody. Be honest about its scope: run here, it
   audits only the components this site has installed, which is how the
   original audit found two broken references where canon had seventeen. The
   canon-wide lint belongs in the library, where every component is present;
   this script's job is the installed contract.

## Verification

Adding a token whose value equals the fallback it replaces changes nothing on
screen. Prove that rather than assume it: build before and after, then compare
computed styles across a few pages, the same method used when cascade layers
were turned on. A difference means the fallback and the new token value are
not actually the same.

## Coordination

The two halves must land together in the direction that keeps sites working:
this starter can define a token before canon uses it, but canon must not
reference a token before the starter ships it. A component that names a token
nobody defines was the case in section 2 above, and it failed silently.

---

## Update 2026-07-25: what the library shipped, and what that changes here

The library completed its side through v1.4.0. Three things affect the work
above; this section is what makes a fresh session on this document
self-sufficient.

**Canon has the lint now.** `npm run lint:components` in the library repo
checks every component for undefined token references, unprefixed component
properties, layer-unsafe stylesheets, and fields-vs-validation default
drift. It takes `--vocab <dir>`, so the cross-repo contract check is one
command from the library checkout:

```shell
npm run lint:components -- --vocab ../path/to/starter/lib/assets/styles
```

That run is currently error-clean, meaning canon references no token this
starter does not ship. The planned `scripts/token-contract.mjs` here can be
thin: its remaining job is the installed-contract check against this site's
actual component set, and it can borrow the parsing from the library's
`scripts/component-lint.mjs`.

**The fallback-only list is longer than eight.** The library lint's warning
list is the authoritative census. Beyond the eight in section 3, canon
components consume with fallback-only values: `--font-size-s`, `--font-size-m`,
`--font-size-xs`, `--text-color`, `--color-text-secondary` (maps,
related-posts — a foreign naming scheme; the library should map these to the
real vocabulary rather than this starter adopting the names), and
`--color-accent`, `--color-hover`, `--color-text-muted`, `--spacing-md`,
`--section-padding`, `--max-width` (calendar, same situation). The decision
rule from step 1 applies: single-component names belong in that component's
`--<component>-*` namespace on the library side, not in this vocabulary.
Note `--commons-content-gap` and `--commons-max-width` now mediate
`--content-gap` and `--wrapper-max-width` through fallback chains, so
defining either token here keeps working unchanged.

**The vendor-layer trap applies to this starter.** Vendor stylesheets
(Shikwasa, Leaflet, OpenLayers) are injected at runtime as plain `<link>`
elements, which are unlayered, and unlayered CSS beats every cascade layer —
including `site` overrides. The library's own site fixes this by wrapping
vendor CSS in a `vendor` layer at copy time and ordering the cascade
`tokens, base, vendor, components, site` (vendor above base so widgets beat
generic element styles, below components so a component that deliberately
restyles a widget wins). See the vendor-copy step in the library's
`metalsmith.js`; this starter's build should mirror it, and the layer order
in `site-config.js` gains the `vendor` entry.

---

## Update 2026-07-25 (later the same day): starter side done

The four work items above are complete. What happened, and the state left
behind:

**Components were brought current first.** The audit only means something
against the components as canon ships them, so the stale ones were
reinstalled from the 1.4.0 catalog before anything else: banner, button,
commons, lottie, multi-media, text, video, collection-pagination, hero, plus
disclosure, which arrived as a new dependency. That picked up the section 2
fixes for the two components installed here (`button`, `collection-pagination`).
`components:status` now reports everything current except `featured-posts`,
which is local-only by design. Each install is its own commit, per the
installer's convention.

**The vocabulary decisions (step 1 and 2).** Five of the fallback-only
tokens are consumed by more than one component or are layout-wide, so they
are now defined in `_design-tokens.css`, each with exactly the value its
fallbacks already carried, so the change is behaviour-neutral by
construction:

| Token | Value | Consumed by |
|---|---|---|
| `--wrapper-max-width` | `85rem` | commons, multi-media |
| `--content-gap` | `2rem` | commons, blog-author |
| `--flow-space` | `1em` | text (ctas scopes its own) |
| `--font-md` | `1.25rem` | overlay (artwork in canon) |
| `--color-primary-light` | `var(--color-primary)` | slider-pagination, text |

`--color-primary-light` is aliased to the primary on purpose: that is what
the fallbacks resolved to, so it is the neutral default, and the token now
exists for a site to retune to an actual lighter shade.

The other three installed-here candidates were referred to the library as
component properties, per the step 1 decision rule: `--iframe-height`
(iframe should define it, the name already carries the component prefix),
and `--logo-list-height` / `--logo-animation-speed` (logos-list, want
renaming into `--logos-list-*`). The foreign naming schemes in maps,
related-posts, calendar and page-transitions stay library-side mapping
work, as the previous update already concluded.

**Documentation (step 3).** `_design-tokens.css` now opens by stating the
contract: which token groups canon is entitled to rely on, what breaks if a
token is renamed or dropped, and which command audits each direction.

**The audit is repeatable (step 4).** `scripts/token-contract.mjs`, run as
`npm run tokens:check`, audits the installed contract: every `var(--x)` in
every installed component's stylesheets against the vocabulary in
`lib/assets/styles/`, definitions in other installed components,
`lib/overrides/`, and vendor stylesheets when present. Missing token without
fallback is an error and exits 1; fallback-only is a warning; `--strict`
fails on warnings too. The parsing mirrors the library's
`component-lint.mjs` so the two tools agree on what counts as defined.
Current output: 0 errors, 3 warnings, and the 3 are exactly the tokens
referred to the library above. When the library lands those renames and the
components are reinstalled, the run goes clean.

**The vendor layer is declared.** `site-config.js` now orders the cascade
`tokens, base, vendor, components, site`. No installed component ships
vendor CSS today, so the layer is empty; the config comment explains that a
runtime-injected vendor stylesheet must be copied into the build wrapped in
`@layer vendor { ... }` the day one arrives. The starter build does not yet
carry a vendor-copy step, deliberately: none of the vendor packages exist in
this starter's `node_modules`, and a copy step referencing absent packages
would fail. The step belongs with the component whose installation brings
the package in.

**Verification, as prescribed.** Development build before and after the
token changes, then a diff of the built `assets/main.css`. The diff is
exactly the intended change and nothing else: the `@layer` statement gains
`vendor`, and the five tokens appear in `:root`. Production build passes.
The cross-repo lint from the library checkout (`npm run lint:components --
--vocab .../lib/assets/styles`) went from 46 warnings to 37, still zero
errors; everything remaining is library-side work.

**What remains, all of it in the library's court:** the component-property
renames for logos-list and iframe, and mapping the foreign naming schemes
(maps, related-posts, calendar, page-transitions) into the real vocabulary.
Each one that lands turns into a reinstall here and a shorter
`tokens:check` output.

**Found while verifying: the page shell was in the wrong layer.** The
hamburger menu rendered as a primary-colored button at every viewport
width. Not caused by this session's changes; the pre-session commit builds
byte-identical CSS for that cascade. It dates to turning layers on: the
button component styles the bare `button` element, the shell's resets in
`_header.css` and the `display: none` in `_navigation.css` sat in `base`,
and `components` beats `base` by layer no matter the specificity. Before
layers the shell won those fights on specificity; layers took that away.
The library's own site had already hit this and moved its shell chrome to
the `site` layer. This starter now mirrors that: `_header.css`,
`_footer.css`, `_navigation.css` and `_branding.css` import at
`layer(site)` in `main.css`, and the three feature stylesheets in
`scripts/features.json` inject at `layer(site)` too. `_global.css` stays
in `base` on purpose: its generic element styles (a, svg, headings) are
exactly what components should beat. Verified in the browser at 1400px
and 500px: hamburger hidden on desktop and unstyled on mobile, the menu
opens and closes, and real `.button` CTAs keep their component styling.
