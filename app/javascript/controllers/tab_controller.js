import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  
  connect() {
    // Show the first tab by default
    if (this.tabTargets.length > 0 && this.panelTargets.length > 0) {
      this.select({ currentTarget: this.tabTargets[0] })
    }
    
    // Check if URL has a hash to select specific tab
    if (window.location.hash) {
      const tabId = window.location.hash.substring(1)
      const tab = this.tabTargets.find(tab => tab.id === tabId || tab.dataset.tab === tabId)
      if (tab) {
        this.select({ currentTarget: tab })
      }
    }
  }
  
  select(event) {
    const selectedTab = event.currentTarget
    const selectedPanel = this.panelTargets.find(panel => panel.dataset.panel === selectedTab.dataset.tab)
    
    // Hide all panels
    this.panelTargets.forEach(panel => {
      panel.classList.add('hidden')
      panel.classList.remove('tab-active:block')
    })
    
    // Deactivate all tabs
    this.tabTargets.forEach(tab => {
      tab.setAttribute('aria-selected', 'false')
      tab.classList.remove('text-indigo-600', 'border-indigo-500')
      tab.classList.add('text-gray-500', 'border-transparent')
    })
    
    // Activate selected tab and panel
    selectedTab.setAttribute('aria-selected', 'true')
    selectedTab.classList.remove('text-gray-500', 'border-transparent')
    selectedTab.classList.add('text-indigo-600', 'border-indigo-500')
    
    selectedPanel.classList.remove('hidden')
    selectedPanel.classList.add('tab-active:block')
    
    // Update URL hash without scrolling
    history.replaceState(null, null, `#${selectedTab.dataset.tab}`)
  }
}