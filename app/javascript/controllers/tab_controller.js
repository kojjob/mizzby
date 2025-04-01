import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { 
    default: { type: String, default: "popular" }
  }

  connect() {
    // Set the default active tab
    this.activeTab = this.defaultValue
    this.updateActiveTab()
    
    // Make this controller accessible to Alpine
    if (window.Alpine) {
      window.Alpine.store('tabs', {
        activeTab: this.activeTab,
        setActiveTab: (tab) => {
          this.activeTab = tab
          this.updateActiveTab()
          window.Alpine.store('tabs').activeTab = tab
        }
      })
    }
  }
  
  change(event) {
    const tabId = event.currentTarget.dataset.tabId
    this.activeTab = tabId
    this.updateActiveTab()
    
    // Update Alpine store if available
    if (window.Alpine && window.Alpine.store('tabs')) {
      window.Alpine.store('tabs').activeTab = tabId
    }
  }
  
  updateActiveTab() {
    // Update tab styles
    this.tabTargets.forEach(tab => {
      const isActive = tab.dataset.tabId === this.activeTab
      tab.classList.toggle('active-tab', isActive)
      tab.setAttribute('aria-selected', isActive)
      
      // Apply active styles
      if (isActive) {
        tab.classList.add('border-indigo-500', 'text-indigo-600')
        tab.classList.remove('border-transparent', 'text-gray-500', 'hover:text-gray-700', 'hover:border-gray-300')
      } else {
        tab.classList.remove('border-indigo-500', 'text-indigo-600')
        tab.classList.add('border-transparent', 'text-gray-500', 'hover:text-gray-700', 'hover:border-gray-300')
      }
    })
    
    // Update panel visibility
    this.panelTargets.forEach(panel => {
      const shouldShow = panel.dataset.tabId === this.activeTab
      panel.classList.toggle('hidden', !shouldShow)
    })
  }
}
