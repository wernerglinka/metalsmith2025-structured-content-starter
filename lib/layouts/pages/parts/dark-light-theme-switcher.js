/**
 * Dark/light theme switcher.
 *
 * Self-contained: applies the saved theme on load and toggles it on click,
 * persisting the choice to localStorage. Safe to load on pages without the
 * toggle button (the click handler is only bound when the button exists).
 *
 * The switch toggles a `dark-theme` class on <body>. The dark design-token
 * values live in the `body.dark-theme` block in
 * lib/shell/styles/_design-tokens.css; retune them there.
 *
 * The class is normally already set before first paint by the inline
 * script in pages/parts/theme-init.njk; applySavedTheme here uses the
 * same rules (saved choice, else system preference) so the two never
 * disagree.
 */

const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)');

/**
 * Read the saved theme. Storage can be blocked, in which case nothing is saved.
 * @returns {string|null} 'dark', 'light' or null
 */
function readSavedTheme() {
  try {
    return localStorage.getItem('theme');
  } catch {
    return null;
  }
}

/**
 * Apply the saved theme, or the system preference when nothing is saved,
 * to <body>.
 * @returns {void}
 */
function applySavedTheme() {
  const theme = readSavedTheme();
  const isDark = theme ? theme === 'dark' : systemPrefersDark.matches;
  document.body.classList.toggle('dark-theme', isDark);
  document.querySelector('.js-theme-toggle')?.setAttribute('aria-pressed', String(isDark));
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
  themeToggle.setAttribute('aria-pressed', String(document.body.classList.contains('dark-theme')));

  themeToggle.addEventListener('click', () => {
    const isDark = document.body.classList.toggle('dark-theme');
    themeToggle.setAttribute('aria-pressed', String(isDark));
    try {
      localStorage.setItem('theme', isDark ? 'dark' : 'light');
    } catch {
      // Storage can be blocked; the theme still applies to this page
    }
  });
}

// Follow a choice made in another tab, and the system preference while
// nothing is saved. applySavedTheme checks the saved choice itself.
window.addEventListener('storage', (event) => {
  if (event.key === 'theme') {
    applySavedTheme();
  }
});
systemPrefersDark.addEventListener('change', applySavedTheme);

applySavedTheme();

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initThemeToggle);
} else {
  initThemeToggle();
}
