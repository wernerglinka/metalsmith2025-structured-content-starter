/**
 * Dark/light theme switcher.
 *
 * Self-contained: applies the saved theme on load and toggles it on click,
 * persisting the choice to localStorage. Safe to load on pages without the
 * toggle button (the click handler is only bound when the button exists).
 *
 * The switch toggles a `dark-theme` class on <body>. The dark design-token
 * values live in the `body.dark-theme` block in
 * lib/assets/styles/_design-tokens.css; retune them there.
 *
 * The class is normally already set before first paint by the inline
 * script in pages/parts/theme-init.njk; applySavedTheme here uses the
 * same rules (saved choice, else system preference) so the two never
 * disagree.
 */

/**
 * Apply the saved theme, or the system preference when nothing is saved,
 * to <body>.
 * @returns {void}
 */
function applySavedTheme() {
  const theme = localStorage.getItem('theme');
  const isDark = theme ? theme === 'dark' : window.matchMedia('(prefers-color-scheme: dark)').matches;
  document.body.classList.toggle('dark-theme', isDark);
}

/**
 * Bind the toggle button, if present on the page.
 * @returns {void}
 */
function initThemeToggle() {
  const themeToggle = document.querySelector('.js-theme-toggle');
  if (!themeToggle) {
    return;
  }
  themeToggle.addEventListener('click', () => {
    const isDark = document.body.classList.toggle('dark-theme');
    localStorage.setItem('theme', isDark ? 'dark' : 'light');
  });
}

applySavedTheme();

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initThemeToggle);
} else {
  initThemeToggle();
}
