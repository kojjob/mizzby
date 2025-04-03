// Tab functionality helper
document.addEventListener('DOMContentLoaded', function() {
  // Find all tab groups
  const tabGroups = document.querySelectorAll('[data-controller="tab"]');
  
  tabGroups.forEach(tabGroup => {
    const tabs = tabGroup.querySelectorAll('[data-tab-target="tab"]');
    const panels = tabGroup.querySelectorAll('[data-tab-target="panel"]');
    
    tabs.forEach((tab, index) => {
      tab.addEventListener('click', function() {
        // Deactivate all tabs
        tabs.forEach(t => {
          t.classList.remove('active', 'border-indigo-500', 'text-indigo-600');
          t.classList.add('border-transparent', 'text-gray-500', 'hover:text-gray-700', 'hover:border-gray-300');
          t.setAttribute('aria-selected', 'false');
        });
        
        // Activate the clicked tab
        tab.classList.remove('border-transparent', 'text-gray-500', 'hover:text-gray-700', 'hover:border-gray-300');
        tab.classList.add('active', 'border-indigo-500', 'text-indigo-600');
        tab.setAttribute('aria-selected', 'true');
        
        // Hide all panels
        panels.forEach(panel => {
          panel.classList.add('hidden');
        });
        
        // Show the corresponding panel
        if (panels[index]) {
          panels[index].classList.remove('hidden');
        }
      });
    });
    
    // Activate the first tab by default if none is active
    if (!tabGroup.querySelector('[data-tab-target="tab"].active')) {
      const firstTab = tabs[0];
      const firstPanel = panels[0];
      
      if (firstTab && firstPanel) {
        firstTab.classList.remove('border-transparent', 'text-gray-500', 'hover:text-gray-700', 'hover:border-gray-300');
        firstTab.classList.add('active', 'border-indigo-500', 'text-indigo-600');
        firstTab.setAttribute('aria-selected', 'true');
        
        firstPanel.classList.remove('hidden');
      }
    }
  });
  
  console.log('Tab helper JavaScript initialized');
});
