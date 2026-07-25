/**
 * Flip Card Component
 * Provides interactive flip card functionality with hover, touch, and keyboard support
 */

/**
 * Adds event listeners to a single flip card
 * @param {HTMLElement} flipCard - The flip card element
 */
const initFlipCard = (flipCard) => {
  // Skip if already initialized
  if (flipCard.dataset.initialized) {
    return;
  }
  flipCard.dataset.initialized = 'true';

  // The wrapper is the single interactive control: hover flips on
  // hover-capable devices, click covers touch, keyboard toggles everywhere
  const canHover = window.matchMedia('(hover: hover)').matches;

  const setFlipped = (flipped) => {
    flipCard.classList.toggle('flip', flipped);
    flipCard.setAttribute('aria-pressed', String(flipped));
  };

  const toggleFlip = () => setFlipped(!flipCard.classList.contains('flip'));

  flipCard.setAttribute('role', 'button');
  flipCard.setAttribute('tabindex', '0');
  flipCard.setAttribute('aria-pressed', 'false');

  if (canHover) {
    flipCard.addEventListener('mouseenter', () => setFlipped(true));
    flipCard.addEventListener('mouseleave', () => setFlipped(false));
  } else {
    flipCard.addEventListener('click', (e) => {
      // Let CTA links and buttons inside the card work normally
      if (e.target.closest('a, button')) {
        return;
      }
      toggleFlip();
    });
  }

  flipCard.addEventListener('keydown', (e) => {
    if ((e.key === 'Enter' || e.key === ' ') && !e.target.closest('a, button')) {
      e.preventDefault();
      toggleFlip();
    }
  });
};

/**
 * Initialize all flip cards on the page
 */
function initFlipCards() {
  const flipCards = document.querySelectorAll('.flip-card-wrapper');
  flipCards.forEach(initFlipCard);
}

// Register with page transitions for SWUP support
if (window.PageTransitions) {
  window.PageTransitions.registerComponent('flip-card', initFlipCards);
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initFlipCards);
} else {
  initFlipCards();
}
