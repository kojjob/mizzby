// Header functionality for non-Stimulus elements

document.addEventListener('DOMContentLoaded', function() {
  // Fallback for mobile menu toggle if not handled by Stimulus
  const mobileMenuButtons = document.querySelectorAll('[data-action="click->header#toggleMobileMenu"]')
  const mobileMenu = document.getElementById('mobile-menu')
  
  if (mobileMenuButtons.length > 0 && mobileMenu) {
    // Check if the element has a Stimulus controller
    const hasController = mobileMenuButtons[0].closest('[data-controller="header"]')
    
    // Only add event listener if not controlled by Stimulus
    if (!hasController) {
      mobileMenuButtons.forEach(button => {
        button.addEventListener('click', function() {
          const isHidden = mobileMenu.classList.contains('hidden')
          const menuIcon = document.querySelector('[data-header-target="menuIcon"]')
          const closeIcon = document.querySelector('[data-header-target="closeIcon"]')
          
          if (isHidden) {
            // Show menu
            mobileMenu.classList.remove('hidden')
            
            if (menuIcon && closeIcon) {
              menuIcon.classList.add('hidden')
              closeIcon.classList.remove('hidden')
            }
            
            // Add animation classes
            setTimeout(() => {
              mobileMenu.classList.add('max-h-screen', 'opacity-100')
              mobileMenu.classList.remove('max-h-0', 'opacity-0')
            }, 10)
          } else {
            // Hide menu with animation
            mobileMenu.classList.add('max-h-0', 'opacity-0')
            mobileMenu.classList.remove('max-h-screen', 'opacity-100')
            
            if (menuIcon && closeIcon) {
              menuIcon.classList.remove('hidden')
              closeIcon.classList.add('hidden')
            }
            
            // After animation completes, add hidden class
            setTimeout(() => {
              mobileMenu.classList.add('hidden')
            }, 300)
          }
        })
      })
    }
  }
  
  // Fix any SVG path errors
  document.querySelectorAll('svg path').forEach(path => {
    // Check for specific broken paths and fix them
    const d = path.getAttribute('d')
    if (d && d.includes('140 8')) {
      // Replace problematic path value
      path.setAttribute('d', 'M3 10h7a4 4 0 0 1 0 8h-7v4h12a4 4 0 0 0 0-8h-5')
    }
  })
})
