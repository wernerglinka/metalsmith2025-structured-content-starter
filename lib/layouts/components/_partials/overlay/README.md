# Overlay Component

Shared modal dialog for components that show content above the page. It is used by the `video` partial (modal player), the `artwork` section (enlarged image), the `team-grid` section (member bios) and the `calendar` section (event details panel). The overlay has no template of its own and is not placed in frontmatter; a component pulls it in by listing `overlay` in its manifest `requires` and importing the helper.

## Files

- `modules/modal-dialog.js`: builds or enhances a native `<dialog>` and exports `createModalDialog`, `enhanceModalDialog` and `closeModalDialog`
- `overlay.css`: the shared `.modal-dialog` styles (backdrop, fades, Close control)
- `overlay.njk`: placeholder, renders nothing

## What the browser provides

The dialog is opened with `showModal()`, so the platform handles the top layer (no `z-index`), makes the page behind inert, keeps focus inside, closes on Escape and the mobile back gesture, and returns focus to the trigger. None of that is scripted here.

## What the helper adds

- **Light dismiss**: `closedby="any"` closes on a backdrop click. Where `closedby` is unsupported (Safari), a small pointer-position fallback does the same
- **Fade out**: a closed dialog leaves the top layer at once, so the helper sets `data-closing`, waits for the CSS transition, then calls `close()`. This works in every browser
- **Close control**: a text-only "Close" button with `autofocus`

The fade in uses `@starting-style`. Both fades run 0.3s, shortened to 0.1s under `prefers-reduced-motion: reduce`. Scroll is contained with `overscroll-behavior: contain` on the dialog and its backdrop; no class is set on `<body>`.

## Usage

```javascript
import { closeModalDialog, createModalDialog } from '../../_partials/overlay/modules/modal-dialog.js';

const { dialog, content } = createModalDialog({
  className: 'my-dialog', // added next to `modal-dialog`
  label: 'Accessible name of the dialog',
  closeLabel: 'Close my thing' // must contain the visible text "Close"
});

// Every way of closing ends in the close event: tear content down here
dialog.addEventListener('close', () => content.replaceChildren());

content.replaceChildren(someElement);
trigger.focus(); // so focus returns to the trigger, also in Safari
dialog.showModal();

// Later
closeModalDialog(dialog); // fades out
closeModalDialog(dialog, { immediate: true }); // e.g. before a page transition
```

Create the dialog once and reuse it; `createModalDialog` appends it to `<body>`.

### A dialog that is already in the markup

When the dialog's content is rendered by the template (as in `team-grid`), give it the `modal-dialog` class and pass it to `enhanceModalDialog`. That adds light dismiss and the fade out; you supply your own close button.

```javascript
import { closeModalDialog, enhanceModalDialog } from '../../_partials/overlay/modules/modal-dialog.js';

enhanceModalDialog(dialog);
trigger.addEventListener('click', () => {
  trigger.focus();
  dialog.showModal();
});
closeButton.addEventListener('click', () => closeModalDialog(dialog));
```

### Non-modal panels

`closeModalDialog` also works for a dialog opened with `dialog.show()`, such as the calendar's event details panel. Style the open state as `[open]:not([data-closing])` and the helper lets the exit transition finish before it closes the dialog.

## Generated markup

```html
<dialog class="modal-dialog my-dialog" aria-label="…" closedby="any">
  <button type="button" class="close" aria-label="…" autofocus>Close</button>
  <div class="modal-dialog-content"><!-- your content --></div>
</dialog>
```

## Styling

Size the dialog and style its content through your own class. The shared styles reset the dialog box (no padding, border or background), so the dialog is exactly as large as the Close control plus your content. A click outside that box lands on the backdrop and dismisses the dialog.

```css
.my-dialog {
  width: min(80vw, 60rem);
}
```

## Browser support

`<dialog>` and `showModal()` are Baseline Widely Available. `closedby` and `@starting-style` are newer; without `closedby` the fallback handles light dismiss, and without `@starting-style` the dialog opens without the fade in.
