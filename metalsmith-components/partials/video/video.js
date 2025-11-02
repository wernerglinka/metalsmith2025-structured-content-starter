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
const initinSitu = async ( element ) => {
  const videoId = element.dataset.videoid;
  const provider = element.dataset.videosrc || 'youtube';
  const cloudName = element.dataset.cloudname;
  const startTime = element.dataset.starttime;
  const endTime = element.dataset.endtime;

  if ( !element.id ) {
    element.id = `inSitu-${ provider }-${ Date.now() }`;
  }

  const providerFn = providers[ provider ]?.inSitu;
  if ( !providerFn ) {
    console.warn( `Unsupported provider: ${ provider }` );
    return;
  }

  const options = { startTime, endTime };
  const playerRef = provider === 'cloudinary'
    ? await providerFn( element, videoId, cloudName )
    : await providerFn( element, videoId, options );

  // Store reference for stopping
  if ( playerRef ) {
    element._playerRef = playerRef;
  }
};

/**
 * Initialize component
 */
const init = () => {
  // Global event listeners for provider communication
  document.addEventListener( 'video-starting', () => {
    stopActivePlayer( activePlayer );
    activePlayer = null;
  } );

  document.addEventListener( 'video-ready', ( e ) => {
    activePlayer = { stop: () => e.detail?.pause?.() || e.detail?.pauseVideo?.() };
  } );

  document.addEventListener( 'video-ended', () => {
    closeModal();
    activePlayer = null;
  } );

  document.addEventListener( 'modal-opening', () => {
    // Close all playing inSitu videos when modal opens
    document.querySelectorAll( '.video-playing' ).forEach( container => {
      container.classList.remove( 'video-playing' );
    } );
    stopActivePlayer( activePlayer );
    activePlayer = null;
  } );

  // Modal videos
  document.querySelectorAll( '.js-modal-video' ).forEach( trigger => {
    trigger.addEventListener( 'click', ( e ) => {
      e.preventDefault();
      handleModalClick( trigger, providers, ( player ) => { activePlayer = player; } );
    } );
  } );

  // inSitu videos with lazy loading
  const inSituVideos = document.querySelectorAll( '.js-in-situ-video' );

  const observer = createVideoObserver( ( target ) => {
    initinSitu( target );
    observer.unobserve( target );
  } );

  if ( observer ) {
    inSituVideos.forEach( video => {
      if ( video.dataset.lazy !== 'false' ) {
        observer.observe( video );
      } else {
        initinSitu( video );
      }
    } );
  } else {
    inSituVideos.forEach( initinSitu );
  }
};

// Auto-initialize
if ( document.readyState === 'loading' ) {
  document.addEventListener( 'DOMContentLoaded', init );
} else {
  init();
}