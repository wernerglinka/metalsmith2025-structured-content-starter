/**
 * Cloudinary Video Provider
 */

import loadScript from '../helpers/load-script.js';
import loadStyles from '../helpers/load-styles.js';

// Pinned player version; @latest would pick up breaking upstream releases
// without warning. The player stays on the CDN because it is a large SDK
// tied to the Cloudinary service.
const PLAYER_CSS = 'https://unpkg.com/cloudinary-video-player@4.0.3/dist/cld-video-player.min.css';
const PLAYER_JS = 'https://unpkg.com/cloudinary-video-player@4.0.3/dist/cld-video-player.min.js';

/**
 * Cloudinary Modal Player
 */
export const createCloudinaryModal = async (videoId, targetId, cloudName) => {
  await Promise.all([loadStyles(PLAYER_CSS), loadScript(PLAYER_JS)]);

  const videoElement = document.createElement('video');
  videoElement.id = `${targetId}-video`;
  videoElement.controls = true;
  videoElement.autoplay = true;
  videoElement.className = 'cld-video-player';
  videoElement.dataset.cldPublicId = videoId;

  document.getElementById(targetId).appendChild(videoElement);

  const player = cloudinary.videoPlayer(videoElement.id, {
    cloudName,
    playedEventPercents: [100]
  });

  player.on('percentsplayed', (data) => {
    if (data.percent === 100) {
      document.dispatchEvent(new CustomEvent('video-ended'));
    }
  });

  return player;
};

/**
 * Cloudinary inSitu Player
 */
export const createCloudinaryinSitu = async (element, videoId, cloudName) => {
  const container = element.closest('.video');
  const trigger = container?.querySelector('.video-trigger');
  const close = container?.querySelector('.close');

  if (!trigger) {
    return null;
  }

  let player = null;

  trigger.onclick = async () => {
    if (!player) {
      document.dispatchEvent(new CustomEvent('video-starting'));

      await Promise.all([loadStyles(PLAYER_CSS), loadScript(PLAYER_JS)]);

      const videoElement = document.createElement('video');
      videoElement.id = `${element.id}-video`;
      videoElement.controls = true;
      videoElement.className = 'cld-video-player';
      videoElement.dataset.cldPublicId = videoId;

      element.appendChild(videoElement);

      player = cloudinary.videoPlayer(videoElement.id, {
        cloudName,
        autoplay: true
      });

      document.dispatchEvent(new CustomEvent('video-ready', { detail: player }));

      player.on('ended', () => {
        container.classList.remove('video-playing');
      });
    }

    container.classList.add('video-playing');
    if (player.play) {
      player.play();
    }
  };

  if (close) {
    close.onclick = () => {
      container.classList.remove('video-playing');
      if (player?.pause) {
        player.pause();
      }
      // Return focus to the trigger; the close button fades out
      trigger.focus();
    };
  }

  // Listen for modal opening to stop this video
  const stopOnModalOpen = () => {
    if (container.classList.contains('video-playing')) {
      container.classList.remove('video-playing');
      if (player?.pause) {
        player.pause();
      }
    }
  };

  document.addEventListener('modal-opening', stopOnModalOpen);

  return {
    element,
    stop: () => player?.pause?.(),
    cleanup: () => document.removeEventListener('modal-opening', stopOnModalOpen)
  };
};
