# CSS cleanup: the token contract between this starter and the library

Working notes written 2026-07-25, to be picked up in a later session. This is
starter-side work. The library has its own list in that repository's
`update.md`, and the two halves are described below so whoever does either one
can see the whole picture.

Nothing here is broken enough to block a site. Two items render incorrectly
today, and the rest is the difference between "works" and "themeable".

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

### 2. Broken references (library fixes these)

Two declarations resolve to nothing and are dropped at computed-value time, so
they silently do not apply:

| Token | Component | Used for |
|---|---|---|
| `--default-letter-spacing` | `button` | `letter-spacing` on every button |
| `--space-lg` | `collection-pagination` | wrapper margin, and icon width/height |

`--space-lg` looks like a naming slip: this starter's scale runs `--space-l`
and `--space-l-xl`, with no `lg`. Whether the fix is to correct canon's
reference or to add the name here is the library's call, but it should be one
or the other rather than both.

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
   subtly wrong and warns nobody.

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
nobody defines is the case in section 2 above, and it fails silently.
