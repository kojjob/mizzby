import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  
  connect() {
    // Set initial active tab
    this.showTab(this.tabTargets[0]?.dataset.tabId || 'csv')
  }
  
  switch(event) {
    event.preventDefault()
    const tabId = event.currentTarget.dataset.tabId
    this.showTab(tabId)
  }
  
  showTab(tabId) {
    // Update tab styles
    this.tabTargets.forEach(tab => {
      if (tab.dataset.tabId === tabId) {
        tab.classList.add('bg-white', 'text-gray-900', 'shadow-sm')
        tab.classList.remove('text-gray-600')
      } else {
        tab.classList.remove('bg-white', 'text-gray-900', 'shadow-sm')
        tab.classList.add('text-gray-600')
      }
    })
    
    // Show/hide panels
    this.panelTargets.forEach(panel => {
      if (panel.dataset.tabId === tabId) {
        panel.classList.remove('hidden')
        // Animate in
        panel.style.opacity = '0'
        panel.style.transform = 'translateY(10px)'
        setTimeout(() => {
          panel.style.transition = 'all 0.3s ease-out'
          panel.style.opacity = '1'
          panel.style.transform = 'translateY(0)'
        }, 10)
      } else {
        panel.classList.add('hidden')
      }
    })
  }
}
