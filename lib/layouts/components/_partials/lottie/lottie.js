/**
 * Lottie Component
 * Loads the lottie-player web component once per session. The custom element
 * upgrades any <lottie-player> markup automatically, including markup swapped
 * in by SWUP page transitions, so no per-element initialization is needed.
 */

const PLAYER_SRC = 'https://unpkg.com/@lottiefiles/lottie-player@2.0.12/dist/lottie-player.js';

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
  if (document.querySelector('lottie-player')) {
    loadLottiePlayer().catch((error) => console.error(error));
  }
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
