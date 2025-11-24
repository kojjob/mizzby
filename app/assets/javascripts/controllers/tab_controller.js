// Tab controller
(function() {
  const application = window.Stimulus ? window.Stimulus.application : null;
  
  if (!application) {
    console.warn('Stimulus application not found for tab_controller');
    return;
  }
  
  application.register('tab', class extends window.Stimulus.Controller {
    static targets = ["tab", "panel"];
    
    connect() {
      console.log("Tab controller connected");
      
      // If no active tab, activate the first one
      if (!this.activeTab) {
        this.activateTab(0);
      }
    }
    
    change(event) {
      // Find the index of the clicked tab
      const clickedTab = event.currentTarget;
      const tabIndex = this.tabTargets.indexOf(clickedTab);
      
      if (tabIndex !== -1) {
        this.activateTab(tabIndex);
      }
    }
    
    activateTab(index) {
      // Deactivate all tabs and hide all panels
      this.tabTargets.forEach((tab, i) => {
        if (i === index) {
          // Activate this tab
          tab.classList.remove('border-transparent', 'text-gray-500', 'hover:text-gray-700', 'hover:border-gray-300');
          tab.classList.add('border-indigo-500', 'text-indigo-600');
          tab.setAttribute('aria-selected', 'true');
          
          // Show corresponding panel
          if (this.panelTargets[i]) {
            this.panelTargets[i].classList.remove('hidden');
          }
        } else {
          // Deactivate this tab
          tab.classList.add('border-transparent', 'text-gray-500', 'hover:text-gray-700', 'hover:border-gray-300');
          tab.classList.remove('border-indigo-500', 'text-indigo-600');
          tab.setAttribute('aria-selected', 'false');
          
          // Hide corresponding panel
          if (this.panelTargets[i]) {
            this.panelTargets[i].classList.add('hidden');
          }
        }
      });
    }
    
    get activeTab() {
      return this.tabTargets.find(tab => tab.getAttribute('aria-selected') === 'true');
    }
  });
})();
