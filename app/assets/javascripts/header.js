// Header functionality
document.addEventListener('DOMContentLoaded', function() {
  // Mobile menu toggle
  const mobileMenuToggle = document.querySelector('[data-action="click->mobile-menu#toggle"]');
  const mobileMenu = document.querySelector('[data-mobile-menu-target="menu"]');
  const openIcon = document.querySelector('[data-mobile-menu-target="openIcon"]');
  const closeIcon = document.querySelector('[data-mobile-menu-target="closeIcon"]');
  
  if (mobileMenuToggle && mobileMenu) {
    mobileMenuToggle.addEventListener('click', function() {
      const isMenuHidden = mobileMenu.classList.contains('hidden');
      
      if (isMenuHidden) {
        // Show menu
        mobileMenu.classList.remove('hidden');
        if (openIcon && closeIcon) {
          openIcon.classList.add('hidden');
          closeIcon.classList.remove('hidden');
        }
        // Prevent body scrolling
        document.body.classList.add('overflow-hidden', 'md:overflow-auto');
      } else {
        // Hide menu
        mobileMenu.classList.add('hidden');
        if (openIcon && closeIcon) {
          openIcon.classList.remove('hidden');
          closeIcon.classList.add('hidden');
        }
        // Re-enable body scrolling
        document.body.classList.remove('overflow-hidden', 'md:overflow-auto');
      }
    });
  }
  
  // Handle window resize to reset mobile menu
  window.addEventListener('resize', function() {
    if (window.innerWidth >= 768 && mobileMenu && !mobileMenu.classList.contains('hidden')) {
      mobileMenu.classList.add('hidden');
      if (openIcon && closeIcon) {
        openIcon.classList.remove('hidden');
        closeIcon.classList.add('hidden');
      }
      document.body.classList.remove('overflow-hidden', 'md:overflow-auto');
    }
  });
  
  console.log('Header JavaScript initialized');
});
