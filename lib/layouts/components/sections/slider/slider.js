/**
 * Slider Component
 *
 * Animation Behavior:
 * - Every slide slides in from the right side
 * - Old slide stays in place while new slide covers it
 * - Responsive layout adapts to screen size automatically
 *
 * State Management:
 * - 'is-visible': Final positioned state (slide at translateX(0%))
 * - 'sliding-in': High z-index for incoming slide (z-index: 100)
 * - 'reset': Prevent higher stacking order slides to slide out over new slide
 */

document.addEventListener('DOMContentLoaded', () => {
  /**
   * Navigation Functions
   */
  const showNextSlide = (slider) => {
    slider.currentSlide = (slider.currentSlide + 1) % slider.slides.length;
    updateSlider(slider);
  };

  const showPreviousSlide = (slider) => {
    slider.currentSlide = (slider.currentSlide - 1 + slider.slides.length) % slider.slides.length;
    updateSlider(slider);
  };

  const showSlide = (slider, slideIndex) => {
    slider.currentSlide = slideIndex;
    updateSlider(slider);
  };

  /**
   * Update Slider
   * - Old slides stay in place (keep 'is-visible')
   * - New slide gets high z-index ('sliding-in') and animates ('is-visible')
   * - After animation: cleanup via transitionend handler
   */
  const updateSlider = (slider) => {
    if (slider.currentSlide < 0 || slider.currentSlide >= slider.slides.length) {
      return;
    }

    // Clean up temporary classes
    slider.slides.forEach((slide) => slide.classList.remove('sliding-in'));

    // Set up new slide for animation
    slider.slides[slider.currentSlide].classList.add('sliding-in', 'is-visible');

    // Update pagination and ARIA states
    const paginationButtons = slider.pagination.querySelectorAll('.slider-pagination-button');
    paginationButtons.forEach((button, index) => {
      button.classList.remove('active');
      button.setAttribute('aria-disabled', 'false');

      if (index === slider.currentSlide) {
        button.classList.add('active');
        button.setAttribute('aria-disabled', 'true');
      }
    });
  };

  /**
   * Add pagination event listeners
   */
  const addPaginationListeners = (slider) => {
    slider.pagination.addEventListener('click', (e) => {
      if (e.target.matches('.slider-pagination-button') || e.target.closest('.slider-pagination-button')) {
        const button = e.target.matches('.slider-pagination-button')
          ? e.target
          : e.target.closest('.slider-pagination-button');
        const paginationButtons = slider.pagination.querySelectorAll('.slider-pagination-button');
        const slideIndex = Array.from(paginationButtons).indexOf(button);

        if (slideIndex >= 0 && slideIndex < slider.slides.length) {
          showSlide(slider, slideIndex);
        }
      }
    });
  };

  /**
   * Add keyboard navigation listeners
   */
  const addKeyboardListeners = (slider) => {
    slider.wrapper.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowRight') {
        e.preventDefault();
        showNextSlide(slider);
      } else if (e.key === 'ArrowLeft') {
        e.preventDefault();
        showPreviousSlide(slider);
      }
    });
  };

  /**
   * Add animation cleanup listeners
   */
  const addAnimationListeners = (slider) => {
    slider.slides.forEach((slide, slideIndex) => {
      slide.addEventListener('transitionend', (e) => {
        // When slide animation completes, clean up old slides
        if (slideIndex === slider.currentSlide && slide.classList.contains('is-visible') && e.target === slide) {
          // Remove temporary classes from current slide
          slide.classList.remove('sliding-in');

          // Reset old slides to off-screen position
          slider.slides.forEach((s, index) => {
            if (index !== slider.currentSlide) {
              s.classList.remove('is-visible', 'sliding-in');
              s.classList.add('reset');

              // Restore transitions after reset
              setTimeout(() => {
                s.classList.remove('reset');
              }, 50);
            }
          });
        }
      });
    });
  };

  /**
   * Initialize a single slider instance
   */
  const initSlider = (sliderWrapper) => {
    const slider = {
      wrapper: sliderWrapper,
      pagination: sliderWrapper.querySelector('.slider-pagination'),
      slides: sliderWrapper.querySelectorAll('.slides > li'),
      currentSlide: 0
    };

    // Add all event listeners
    addPaginationListeners(slider);
    addKeyboardListeners(slider);
    addAnimationListeners(slider);

    // Initialize first slide
    updateSlider(slider);
  };

  /**
   * Initialize all sliders on the page
   */
  const sliderWrappers = document.querySelectorAll('.slider-wrapper');

  sliderWrappers.forEach(initSlider);

  // All sliders initialized
});
