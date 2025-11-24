// Simple dropdown handler that doesn't rely on Stimulus
document.addEventListener('DOMContentLoaded', function() {
  // Find all dropdown toggle buttons
  const dropdownButtons = document.querySelectorAll('[data-dropdown-toggle]');
  
  // Add click event listeners to each button
  dropdownButtons.forEach(button => {
    const targetId = button.getAttribute('data-dropdown-toggle');
    const dropdownMenu = document.getElementById(targetId);
    
    if (!dropdownMenu) return;
    
    // Toggle dropdown when button is clicked
    button.addEventListener('click', function(event) {
      event.stopPropagation();
      
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
    });
  });
});
