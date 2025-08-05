document.addEventListener('DOMContentLoaded', () => {
  /**
   * Mobile menu functionality
   * Toggles the mobile menu when the hamburger button is clicked
   */
  const hamburger = document.querySelector('.hamburger-menu');
  const mainMenu = document.querySelector('.main-menu');

  if (hamburger && mainMenu) {
    hamburger.addEventListener('click', function () {
      // Toggle active class on hamburger
      this.classList.toggle('active');

      // Toggle active class on menu
      mainMenu.classList.toggle('active');
    });

    // Close menu when clicking outside
    document.addEventListener('click', (event) => {
      const isClickInside = hamburger.contains(event.target) || mainMenu.contains(event.target);

      if (!isClickInside && mainMenu.classList.contains('active')) {
        mainMenu.classList.remove('active');
        hamburger.classList.remove('active');
      }
    });

    // Close menu when clicking on a menu item (for mobile)
    const menuLinks = mainMenu.querySelectorAll('a');
    menuLinks.forEach((link) => {
      link.addEventListener('click', () => {
        if (window.innerWidth <= 767) {
          mainMenu.classList.remove('active');
          hamburger.classList.remove('active');
        }
      });
    });
  }

  // Show to-top button when scrolling
  window.addEventListener('scroll', () => {
    if (window.scrollY > 0) {
      document.body.classList.add('scrolling');
    } else {
      document.body.classList.remove('scrolling');
    }
  });
});
