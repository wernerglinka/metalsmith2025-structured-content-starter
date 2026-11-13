/**
 * Lottie Component
 * Loads the lottie-player web component once per session. The custom element
 * upgrades any <lottie-player> markup automatically, including markup swapped
 * in by SWUP page transitions, so no per-element initialization is needed.
 */

// Self-hosted copy of @lottiefiles/lottie-player, placed in the build by
// metalsmith.js from node_modules; the version is managed in package.json
const PLAYER_SRC = '/assets/vendor/lottie-player.js';

let loaderPromise = null;

/**
 * Load the lottie-player script exactly once
 * @returns {Promise<void>} Resolves when the custom element is available
 */
const loadLottiePlayer = () => {
  if (loaderPromise) {
    return loaderPromise;
  }
  if (window.customElements?.get('lottie-player')) {
    loaderPromise = Promise.resolve();
    return loaderPromise;
  }

  loaderPromise = new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src = PLAYER_SRC;
    script.async = true;
    script.onload = () => resolve();
    script.onerror = () => {
      loaderPromise = null;
      reject(new Error('Failed to load lottie-player'));
    };
    document.head.appendChild(script);
  });
  return loaderPromise;
};

/**
 * Initialize lottie players on the current page
 */
function initLottie() {
  const players = document.querySelectorAll('lottie-player');
  if (players.length === 0) {
    return;
  }

  // Reduced motion: do not start animations automatically. Show the player's
  // own controls instead, so the visitor can still choose to play them.
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    players.forEach((player) => {
      if (player.hasAttribute('autoplay')) {
        player.removeAttribute('autoplay');
        player.setAttribute('controls', '');
        // Already upgraded (e.g. after a page transition): stop what has started
        player.pause?.();
      }
    });
  }

  loadLottiePlayer().catch((error) => console.error(error));
}

// Register with page transitions for SWUP support
if (window.PageTransitions) {
  window.PageTransitions.registerComponent('lottie', initLottie);
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initLottie);
} else {
  initLottie();
}
