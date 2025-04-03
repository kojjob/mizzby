// Dropdown functionality for header elements
document.addEventListener('DOMContentLoaded', function() {
  // Find all dropdown buttons
  const dropdownButtons = document.querySelectorAll('[data-action*="dropdown#toggle"]');
  
  // Handle dropdowns
  dropdownButtons.forEach(button => {
    // Find the corresponding dropdown menu
    const dropdown = button.closest('[data-controller="dropdown"]');
    const menu = dropdown?.querySelector('[data-dropdown-target="menu"]');
    const arrow = dropdown?.querySelector('[data-dropdown-arrow], [data-dropdown-target="arrow"]');
    
    if (button && menu) {
      // Toggle dropdown on click
      button.addEventListener('click', function(event) {
        event.stopPropagation();
        
        // Close all other dropdowns first
        dropdownButtons.forEach(otherButton => {
          if (otherButton !== button) {
            const otherDropdown = otherButton.closest('[data-controller="dropdown"]');
            const otherMenu = otherDropdown?.querySelector('[data-dropdown-target="menu"]');
            const otherArrow = otherDropdown?.querySelector('[data-dropdown-arrow], [data-dropdown-target="arrow"]');
            
            if (otherMenu && !otherMenu.classList.contains('hidden')) {
              otherMenu.classList.add('hidden');
              if (otherArrow) {
                otherArrow.classList.remove('transform', 'rotate-180');
              }
            }
          }
        });
        
        // Toggle this dropdown
        const isHidden = menu.classList.contains('hidden');
        
        if (isHidden) {
          // Show menu
          menu.classList.remove('hidden');
          if (arrow) {
            arrow.classList.add('transform', 'rotate-180');
          }
        } else {
          // Hide menu
          menu.classList.add('hidden');
          if (arrow) {
            arrow.classList.remove('transform', 'rotate-180');
          }
        }
      });
    }
  });
  
  // Close dropdowns when clicking outside
  document.addEventListener('click', function(event) {
    dropdownButtons.forEach(button => {
      const dropdown = button.closest('[data-controller="dropdown"]');
      const menu = dropdown?.querySelector('[data-dropdown-target="menu"]');
      const arrow = dropdown?.querySelector('[data-dropdown-arrow], [data-dropdown-target="arrow"]');
      
      // If clicking outside the dropdown and the dropdown is open, close it
      if (dropdown && menu && !dropdown.contains(event.target) && !menu.classList.contains('hidden')) {
        menu.classList.add('hidden');
        if (arrow) {
          arrow.classList.remove('transform', 'rotate-180');
        }
      }
    });
  });
  
  console.log('Header dropdowns JavaScript initialized');
});
