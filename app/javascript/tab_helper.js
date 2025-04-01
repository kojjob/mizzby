// Tab helper to ensure ActiveTab is defined for Alpine.js components

document.addEventListener('DOMContentLoaded', function() {
  // Look for elements that use activeTab but don't have it defined
  document.querySelectorAll('[x-show*="activeTab"]').forEach(el => {
    // Check if element is within an Alpine component that defines activeTab
    const withinComponent = !!el.closest('[x-data*="activeTab"]')
    
    // If not within a component that defines activeTab, add x-data
    if (!withinComponent) {
      // Add x-data if not present
      if (!el.hasAttribute('x-data')) {
        el.setAttribute('x-data', '{ activeTab: "popular" }')
        console.log('Added missing x-data with activeTab to element:', el)
      }
    }
  })
  
  // Initialize Alpine globally if needed but not already loaded
  if (!window.Alpine && typeof Alpine !== 'undefined') {
    window.Alpine = Alpine
    
    // Initialize tab store data
    window.Alpine.store('tabs', {
      activeTab: 'popular',
      setActiveTab(tab) {
        this.activeTab = tab
      }
    })
    
    // Start Alpine
    window.Alpine.start()
  }
})
