/**
 * Header Component
 * Handles mobile menu toggle and header search functionality
 */

/**
 * Initialize header functionality when DOM loads
 */
document.addEventListener('DOMContentLoaded', () => {
  initHeaderSearch();
});

/**
 * Initialize header search form
 * Handles search overlay toggle, form submission, and keyboard shortcuts
 */
function initHeaderSearch() {
  const searchToggle = document.querySelector('.search-icon-toggle');
  const searchOverlay = document.querySelector('.header-search-overlay');
  const searchForm = document.querySelector('.header-search-form');
  const searchInput = document.querySelector('#header-search-input');

  if (!searchToggle || !searchOverlay || !searchForm || !searchInput) {
    return;
  }

  // Toggle search overlay visibility
  searchToggle.addEventListener('click', () => {
    const isActive = searchOverlay.classList.contains('active');

    if (isActive) {
      closeSearch();
    } else {
      openSearch();
    }
  });

  // Open search overlay
  function openSearch() {
    searchOverlay.classList.add('active');
    searchToggle.classList.add('search-active');
    searchToggle.setAttribute('aria-expanded', 'true');

    // Focus input after animation completes
    setTimeout(() => {
      searchInput.focus();
    }, 300);
  }

  // Close search overlay
  function closeSearch() {
    searchOverlay.classList.remove('active');
    searchToggle.classList.remove('search-active');
    searchToggle.setAttribute('aria-expanded', 'false');
    searchInput.value = '';
  }

  // Close search when clicking outside
  document.addEventListener('click', (e) => {
    const isClickInsideOverlay = searchOverlay.contains(e.target);
    const isClickOnToggle = searchToggle.contains(e.target);

    if (!isClickInsideOverlay && !isClickOnToggle && searchOverlay.classList.contains('active')) {
      closeSearch();
    }
  });

  // Close search on Escape key
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && searchOverlay.classList.contains('active')) {
      closeSearch();
    }
  });

  // Handle form submission
  searchForm.addEventListener('submit', (e) => {
    e.preventDefault();

    const query = searchInput.value.trim();

    if (query.length === 0) {
      // Focus input if empty
      searchInput.focus();
      return;
    }

    // Redirect to search page with query parameter
    const searchURL = `/search/?q=${encodeURIComponent(query)}`;
    window.location.href = searchURL;
  });

  // Handle keyboard shortcut (Cmd/Ctrl + K) to open search
  document.addEventListener('keydown', (e) => {
    if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
      e.preventDefault();
      if (!searchOverlay.classList.contains('active')) {
        openSearch();
      }
    }
  });
}
