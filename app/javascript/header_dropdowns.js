// This file handles any non-Stimulus dropdown functionality for backwards compatibility

document.addEventListener('DOMContentLoaded', function() {
  // Handle legacy dropdown toggles (data-dropdown-toggle attribute)
  const dropdownToggles = document.querySelectorAll('[data-dropdown-toggle]')
  
  dropdownToggles.forEach(toggle => {
    const targetId = toggle.getAttribute('data-dropdown-toggle')
    const target = document.getElementById(targetId)
    
    if (!target) return
    
    // Skip if already handled by Stimulus
    if (toggle.closest('[data-controller="enhanced-dropdown"]')) return
    
    toggle.addEventListener('click', function(e) {
      e.preventDefault()
      e.stopPropagation()
      
      const expanded = toggle.getAttribute('aria-expanded') === 'true'
      
      // Close all other dropdowns
      document.querySelectorAll('.dropdown-menu').forEach(menu => {
        if (menu !== target && !menu.classList.contains('hidden')) {
          menu.classList.add('hidden')
          menu.classList.remove('opacity-100', 'scale-100')
          menu.classList.add('opacity-0', 'scale-95')
          
          // Find the toggle for this menu
          const menuToggle = document.querySelector(`[data-dropdown-toggle="${menu.id}"]`)
          if (menuToggle) menuToggle.setAttribute('aria-expanded', 'false')
        }
      })
      
      if (expanded) {
        // Hide menu
        target.classList.add('opacity-0', 'scale-95')
        toggle.setAttribute('aria-expanded', 'false')
        
        // After animation, hide completely
        setTimeout(() => {
          target.classList.add('hidden')
        }, 150)
      } else {
        // Show menu
        target.classList.remove('hidden')
        
        // Force reflow
        void target.offsetWidth
        
        target.classList.remove('opacity-0', 'scale-95')
        target.classList.add('opacity-100', 'scale-100')
        toggle.setAttribute('aria-expanded', 'true')
      }
    })
  })
  
  // Close dropdowns when clicking outside
  document.addEventListener('click', function(e) {
    const dropdowns = document.querySelectorAll('.dropdown-menu:not(.hidden)')
    
    dropdowns.forEach(dropdown => {
      // Check if dropdown is controlled by Stimulus
      const stimulusControlled = dropdown.closest('[data-controller="enhanced-dropdown"]')
      if (stimulusControlled) return
      
      // Find the toggle for this dropdown
      const toggleId = dropdown.id
      const toggle = document.querySelector(`[data-dropdown-toggle="${toggleId}"]`)
      
      // Check if click is outside dropdown and toggle
      const isOutside = !dropdown.contains(e.target) && 
                        (!toggle || !toggle.contains(e.target))
      
      if (isOutside) {
        // Hide dropdown
        dropdown.classList.add('opacity-0', 'scale-95')
        dropdown.classList.remove('opacity-100', 'scale-100')
        
        if (toggle) toggle.setAttribute('aria-expanded', 'false')
        
        setTimeout(() => {
          dropdown.classList.add('hidden')
        }, 150)
      }
    })
  })
})
