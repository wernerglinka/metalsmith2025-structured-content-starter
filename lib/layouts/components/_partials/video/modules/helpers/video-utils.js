/**
 * Video Component Utilities
 */

import { closeModalDialog, createModalDialog } from '../../../overlay/modules/modal-dialog.js';

// The one video dialog, created on first use and reused afterwards
let videoDialog = null;

/**
 * Get the shared video dialog, creating it on first use.
 * @returns {{ dialog: HTMLDialogElement, container: HTMLElement }}
 */
export const getVideoDialog = () => {
  if (videoDialog?.isConnected) {
    return { dialog: videoDialog, container: videoDialog.querySelector('.video-container') };
  }

  const { dialog, content } = createModalDialog({
    className: 'video-dialog',
    label: 'Video player',
    closeLabel: 'Close video'
  });
  content.classList.add('video-container');

  // Single teardown path: every way of closing ends in the close event
  dialog.addEventListener('close', () => {
    // A detached <video> keeps playing audio, so pause before removing
    content.querySelectorAll('video').forEach((video) => {
      video.pause();
    });
    content.replaceChildren();
  });

  videoDialog = dialog;

  return { dialog, container: content };
};

/**
 * Close the video modal if it is open
 * @param {Object} [options]
 * @param {boolean} [options.immediate=false] - Skip the fade, e.g. before a page transition
 */
export const closeModal = (options) => closeModalDialog(videoDialog, options);

/**
 * Stop active player
 */
export const stopActivePlayer = (activePlayer) => {
  if (!activePlayer?.stop) {
    return;
  }

  try {
    activePlayer.stop();
  } catch (error) {
    console.warn('Error stopping player:', error);
  }
};

/**
 * Handle modal video clicks
 * @param {HTMLButtonElement} trigger - The button that opens the modal
 * @param {Object} providers - Provider factory map
 */
export const handleModalClick = async (trigger, providers) => {
  const videoId = trigger.dataset.videoid;
  const provider = trigger.dataset.videosrc || 'youtube';
  const cloudName = trigger.dataset.cloudname;
  const startTime = trigger.dataset.starttime;
  const endTime = trigger.dataset.endtime;

  const providerFn = providers[provider]?.modal;
  if (!providerFn) {
    console.warn(`Unsupported provider: ${provider}`);
    return;
  }

  // Close any playing in-situ videos before opening modal
  document.dispatchEvent(new CustomEvent('modal-opening'));

  const { dialog, container } = getVideoDialog();

  const targetId = `${provider}-target`;
  const target = document.createElement('div');
  target.id = targetId;
  container.replaceChildren(target);

  // Safari does not focus a button on click; focus it so the dialog
  // returns focus to the trigger when it closes.
  trigger.focus();
  dialog.showModal();

  try {
    const options = { startTime, endTime };
    provider === 'cloudinary'
      ? await providerFn(videoId, targetId, cloudName)
      : await providerFn(videoId, targetId, options);

    // The dialog may have been closed while the provider API was loading
    if (!dialog.open) {
      container.replaceChildren();
    }
  } catch (error) {
    console.error('Error creating player:', error);
    closeModal({ immediate: true });
  }
};
