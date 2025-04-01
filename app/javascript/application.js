// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "./header" // Import header functionality
import "./header_dropdowns" // Import dropdown functionality
import "./alpine_init" // Import Alpine.js initialization
import "./tab_helper" // Import tab helper for Alpine.js

// Set up Alpine tab store globally for tabs that need it
window.initAlpineTabs = function() {
  if (window.Alpine) {
    window.Alpine.store('tabs', {
      activeTab: 'popular',
      setActiveTab(tab) {
        this.activeTab = tab
      }
    })
  }
}

// Initialize Alpine.js if it exists
document.addEventListener('DOMContentLoaded', function() {
  if (typeof Alpine !== 'undefined') {
    // Initialize Alpine.js
    window.Alpine = Alpine
    Alpine.start()

    // Initialize tab store
    Alpine.store('tabs', {
      activeTab: 'popular',
      setActiveTab(tab) {
        this.activeTab = tab
      }
    })
    
    // Initialize layout store
    Alpine.store('layout', {
      mobileMenuOpen: false,
      toggleMobileMenu() {
        this.mobileMenuOpen = !this.mobileMenuOpen
      }
    })
  }
  
  // Fix for the broken SVG paths
  document.querySelectorAll('svg path').forEach(path => {
    const d = path.getAttribute('d')
    if (d && d.includes('140 8')) {
      // Fix the problematic path value
      path.setAttribute('d', 'M3 10h7a4 4 0 0 1 0 8h-7v4h12a4 4 0 0 0 0-8h-5')
    }
  })
})

