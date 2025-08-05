/**
 * Banner with following collapsible content, AKA "Accordion"
 * Banner must be followed by a .js-accordion-content element
 */

document.addEventListener('DOMContentLoaded', () => {
  // Find all accordion instances on the page
  const accordions = document.querySelectorAll('.accordion-header');

  // Initialize each slider independently
  accordions.forEach((accordion) => {
    // accordion contenty must be an immediately following sibling of the banner with class .accordion-content
    const content = accordion.nextElementSibling;
    if (!content.classList.contains('accordion-content')) {
      return;
    }

    // Toggle content visibility
    accordion.addEventListener('click', () => {
      content.classList.toggle('is-closed');
      accordion.classList.toggle('is-open');
    });
  });
});
