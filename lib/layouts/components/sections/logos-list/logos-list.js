/* global window, document */

/**
 * Manage logo display
 * If logos list fits on viewport width its static, if not logos will rotate automatically
 * @params {*} none
 * @return {function} initializes a logo display
 */
document.addEventListener('DOMContentLoaded', () => {
  const allLogosLists = document.querySelectorAll('.js-logos-list');
  const viewportWidth = window.innerWidth;
  allLogosLists.forEach((logosList) => {
    if (logosList.offsetWidth > viewportWidth) {
      logosList.parentElement.classList.add('play');
    } else {
      logosList.parentElement.classList.remove('play');
    }
  });

  const resizeObserver = new ResizeObserver(() => {
    const allLogosLists = document.querySelectorAll('.js-logos-list');
    const viewportWidth = window.innerWidth;
    allLogosLists.forEach((logosList) => {
      if (logosList.offsetWidth > viewportWidth) {
        logosList.parentElement.classList.add('play');
      } else {
        logosList.parentElement.classList.remove('play');
      }
    });
  });

  resizeObserver.observe(document.body);
});
