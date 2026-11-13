/**
 * Modal Dialog Helper
 *
 * Builds a native modal <dialog> for components that show content above the
 * page (video player, enlarged artwork). The browser supplies the top layer,
 * the inert page, focus containment, Escape/back-gesture dismissal and focus
 * return; this module only adds what the platform does not yet do everywhere:
 * a fade out, and light dismiss where <dialog closedby> is unsupported.
 *
 * Styles live in overlay.css (.modal-dialog).
 */

/**
 * Fade the dialog out, then close it.
 * A closed dialog leaves the top layer at once, so the fade has to run while
 * it is still open: [data-closing] switches the CSS to the closed look, and
 * close() follows once that transition has finished. Done this way the fade
 * works in every browser, without relying on `overlay` or discrete `display`
 * transitions.
 * @param {HTMLDialogElement} dialog
 * @returns {Promise<void>}
 */
const fadeOutAndClose = async (dialog) => {
  if (!dialog.open || dialog.hasAttribute('data-closing')) {
    return;
  }
  dialog.setAttribute('data-closing', '');

  // subtree: true includes the ::backdrop transition; the timeout is a safety net
  const animations = dialog.getAnimations({ subtree: true });
  await Promise.race([
    Promise.allSettled(animations.map((animation) => animation.finished)),
    new Promise((resolve) => setTimeout(resolve, 1000))
  ]);

  if (dialog.open) {
    dialog.close();
  }

  // Clear the marker here rather than in a close listener, so this also works
  // for a dialog that was never passed through enhanceModalDialog
  dialog.removeAttribute('data-closing');
};

/**
 * Light-dismiss fallback for browsers without <dialog closedby>.
 * Tests the pointer position rather than event.target, and requires both the
 * press and the release outside, so a drag that ends on the backdrop does not
 * dismiss.
 * @param {HTMLDialogElement} dialog
 */
const addLightDismissFallback = (dialog) => {
  if ('closedBy' in HTMLDialogElement.prototype) {
    return;
  }

  const isOutside = (event) => {
    const rect = dialog.getBoundingClientRect();
    return (
      event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom
    );
  };

  let pressedOutside = false;
  dialog.addEventListener('pointerdown', (event) => {
    pressedOutside = isOutside(event);
  });
  dialog.addEventListener('pointerup', (event) => {
    if (pressedOutside && isOutside(event)) {
      fadeOutAndClose(dialog);
    }
  });
};

/**
 * Add the shared behavior to a <dialog> that already exists in the markup:
 * light dismiss, and a fade out on every way of closing. The caller opens it
 * with `dialog.showModal()`.
 * @param {HTMLDialogElement} dialog
 * @returns {HTMLDialogElement} The same dialog
 */
export const enhanceModalDialog = (dialog) => {
  if (!dialog.hasAttribute('closedby')) {
    dialog.setAttribute('closedby', 'any');
  }

  // Escape, the back gesture and a native backdrop click arrive as a cancel
  // event; route them through the fade instead of closing instantly.
  dialog.addEventListener('cancel', (event) => {
    if (event.cancelable) {
      event.preventDefault();
      fadeOutAndClose(dialog);
    }
  });

  // Closed by other means mid-fade (e.g. an immediate close): reset the marker
  dialog.addEventListener('close', () => {
    dialog.removeAttribute('data-closing');
  });

  addLightDismissFallback(dialog);

  return dialog;
};

/**
 * Close a dialog if it is open, letting its exit transition finish first.
 * Works for modal and non-modal dialogs.
 * @param {HTMLDialogElement|null} dialog
 * @param {Object} [options]
 * @param {boolean} [options.immediate=false] - Skip the fade, e.g. before a page transition
 */
export const closeModalDialog = (dialog, { immediate = false } = {}) => {
  if (!dialog?.open) {
    return;
  }
  if (immediate) {
    dialog.close();
  } else {
    fadeOutAndClose(dialog);
  }
};

/**
 * Create a modal dialog and append it to <body>.
 * The caller fills `content`, opens the dialog with `dialog.showModal()`, and
 * listens for the dialog's `close` event to tear its content down. Every way
 * of closing (Close button, Escape, back gesture, backdrop click,
 * closeModalDialog) ends in that one event.
 * @param {Object} options
 * @param {string} options.className - Component class, added next to `modal-dialog`
 * @param {string} options.label - Accessible name of the dialog
 * @param {string} [options.closeLabel='Close'] - Accessible name of the Close button; must contain "Close"
 * @returns {{ dialog: HTMLDialogElement, content: HTMLElement }}
 */
export const createModalDialog = ({ className, label, closeLabel = 'Close' }) => {
  const dialog = document.createElement('dialog');
  dialog.className = `modal-dialog ${className}`;
  dialog.setAttribute('aria-label', label);

  const closeButton = document.createElement('button');
  closeButton.type = 'button';
  closeButton.className = 'close';
  closeButton.autofocus = true;
  closeButton.setAttribute('aria-label', closeLabel);
  closeButton.textContent = 'Close';
  closeButton.addEventListener('click', () => fadeOutAndClose(dialog));

  const content = document.createElement('div');
  content.className = 'modal-dialog-content';

  enhanceModalDialog(dialog);

  dialog.append(closeButton, content);
  document.body.appendChild(dialog);

  return { dialog, content };
};
