// Alpine.js initialization
document.addEventListener('DOMContentLoaded', () => {
  // Create a global Alpine store for tabs
  if (window.Alpine) {
    window.Alpine.store('tabs', {
      activeTab: 'popular',
      setActiveTab(tab) {
        this.activeTab = tab
      }
    })
    
    // If there's no Stimulus controller handling tabs, Alpine can take over
    window.Alpine.data('tabContainer', () => ({
      activeTab: 'popular',
      
      init() {
        // Try to get active tab from store if available
        if (window.Alpine.store('tabs')) {
          this.activeTab = window.Alpine.store('tabs').activeTab
        }
      },
      
      setTab(tab) {
        this.activeTab = tab
        
        // Update the store if available
        if (window.Alpine.store('tabs')) {
          window.Alpine.store('tabs').activeTab = tab
        }
      }
    }))
  }
})
