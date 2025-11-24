// Simple dropdown handler that doesn't rely on Stimulus
document.addEventListener('DOMContentLoaded', function() {
  console.log('Dropdown fix script loaded');
  
  // Find all dropdown toggle buttons
  const dropdownButtons = document.querySelectorAll('[data-dropdown-toggle]');
  console.log('Found dropdown buttons:', dropdownButtons.length);
  
  // Add click event listeners to each button
  dropdownButtons.forEach(button => {
    const targetId = button.getAttribute('data-dropdown-toggle');
    const dropdownMenu = document.getElementById(targetId);
    
    if (!dropdownMenu) {
      console.warn('Dropdown menu not found for:', targetId);
      return;
    }
    
    console.log('Setting up dropdown:', targetId);
    
    // Toggle dropdown when button is clicked
    button.addEventListener('click', function(event) {
      event.stopPropagation();
      console.log('Button clicked for:', targetId);
      
      // Close all other dropdowns first
      document.querySelectorAll('.dropdown-menu').forEach(menu => {
        if (menu !== dropdownMenu && !menu.classList.contains('hidden')) {
          menu.classList.add('hidden');
        }
      });
      
      // Toggle this dropdown
      dropdownMenu.classList.toggle('hidden');
    });
  });
  
  // Close dropdowns when clicking outside
  document.addEventListener('click', function(event) {
    console.log('Document clicked, closing dropdowns');
    document.querySelectorAll('.dropdown-menu').forEach(menu => {
      if (!menu.classList.contains('hidden')) {
        menu.classList.add('hidden');
      }
    });
  });
  
  // Prevent dropdown from closing when clicking inside it
  document.querySelectorAll('.dropdown-menu').forEach(menu => {
    menu.addEventListener('click', function(event) {
      event.stopPropagation();
      console.log('Click inside dropdown, preventing close');
    });
  });
});
