/**
 * Simple Video Component
 * Three providers (YouTube, Vimeo, Cloudinary) in two modes (inSitu, modal)
 */

import { createYouTubeModal, createYouTubeinSitu } from './modules/providers/youtube.js';
import { createVimeoModal, createVimeoinSitu } from './modules/providers/vimeo.js';
import { createCloudinaryModal, createCloudinaryinSitu } from './modules/providers/cloudinary.js';
import { closeModal, stopActivePlayer, createVideoObserver, handleModalClick } from './modules/helpers/video-utils.js';

// Simple active player state
let activePlayer = null;
let globalListenersInitialized = false;
let inSituObserver = null;

/**
 * Provider factory
 */
const providers = {
  youtube: { modal: createYouTubeModal, inSitu: createYouTubeinSitu },
  vimeo: { modal: createVimeoModal, inSitu: createVimeoinSitu },
  cloudinary: { modal: createCloudinaryModal, inSitu: createCloudinaryinSitu }
};

/**
 * Initialize inSitu video
 */
const initinSitu = async (element) => {
  // Skip if already initialized
  if (element.dataset.initialized) {
    return;
  }
  element.dataset.initialized = 'true';
  const videoId = element.dataset.videoid;
  const provider = element.dataset.videosrc || 'youtube';
  const cloudName = element.dataset.cloudname;
  const startTime = element.dataset.starttime;
  const endTime = element.dataset.endtime;

  if (!element.id) {
    element.id = `inSitu-${provider}-${Date.now()}`;
  }

  const providerFn = providers[provider]?.inSitu;
  if (!providerFn) {
    console.warn(`Unsupported provider: ${provider}`);
    return;
  }

  const options = { startTime, endTime };
  const playerRef =
    provider === 'cloudinary'
      ? await providerFn(element, videoId, cloudName)
      : await providerFn(element, videoId, options);

  // Store reference for stopping
  if (playerRef) {
    element._playerRef = playerRef;
  }
};

/**
 * Initialize global event listeners (only once)
 */
const initGlobalListeners = () => {
  if (globalListenersInitialized) {
    return;
  }
  globalListenersInitialized = true;

  document.addEventListener('video-starting', () => {
    stopActivePlayer(activePlayer);
    activePlayer = null;
  });

  document.addEventListener('video-ready', (e) => {
    activePlayer = { stop: () => e.detail?.pause?.() || e.detail?.pauseVideo?.() };
  });

  document.addEventListener('video-ended', () => {
    closeModal();
    activePlayer = null;
  });

  document.addEventListener('modal-opening', () => {
    document.querySelectorAll('.video-playing').forEach((container) => {
      container.classList.remove('video-playing');
    });
    stopActivePlayer(activePlayer);
    activePlayer = null;
  });
};

/**
 * Initialize component
 */
const init = () => {
  // Initialize global listeners once
  initGlobalListeners();

  // Modal videos
  document.querySelectorAll('.js-modal-video').forEach((trigger) => {
    // Skip if already initialized
    if (trigger.dataset.initialized) {
      return;
    }
    trigger.dataset.initialized = 'true';

    trigger.addEventListener('click', (e) => {
      e.preventDefault();
      handleModalClick(trigger, providers, (player) => {
        activePlayer = player;
      });
    });
  });

  // inSitu videos with lazy loading
  const inSituVideos = document.querySelectorAll('.js-in-situ-video:not([data-initialized])');

  // Disconnect any observer from a previous init before creating a new one
  if (inSituObserver) {
    inSituObserver.disconnect();
  }

  inSituObserver = createVideoObserver((target) => {
    initinSitu(target);
    inSituObserver.unobserve(target);
  });

  if (inSituObserver) {
    inSituVideos.forEach((video) => {
      if (video.dataset.lazy !== 'false') {
        inSituObserver.observe(video);
      } else {
        initinSitu(video);
      }
    });
  } else {
    inSituVideos.forEach(initinSitu);
  }
};

/**
 * Cleanup videos before page transitions
 */
const cleanup = () => {
  if (inSituObserver) {
    inSituObserver.disconnect();
    inSituObserver = null;
  }

  // Invoke provider cleanup functions (remove document-level listeners)
  document.querySelectorAll('.js-in-situ-video[data-initialized]').forEach((element) => {
    element._playerRef?.cleanup?.();
    delete element._playerRef;
  });

  stopActivePlayer(activePlayer);
  activePlayer = null;
};

// Register with page transitions for SWUP support
if (window.PageTransitions) {
  window.PageTransitions.registerComponent('video', init);
  window.PageTransitions.registerCleanup('video', cleanup);
}

// Auto-initialize
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}
