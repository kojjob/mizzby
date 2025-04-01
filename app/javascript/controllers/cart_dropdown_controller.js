import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cart-dropdown"
export default class extends Controller {
  static targets = ["dropdown"]
  
  connect() {
    // Close dropdown when clicking outside
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener('click', this.boundHandleClickOutside)
    
    // Close dropdown when pressing escape
    this.boundHandleEscapeKey = this.handleEscapeKey.bind(this)
    document.addEventListener('keydown', this.boundHandleEscapeKey)
  }
  
  disconnect() {
    document.removeEventListener('click', this.boundHandleClickOutside)
    document.removeEventListener('keydown', this.boundHandleEscapeKey)
  }
  
  toggle(event) {
    event.stopPropagation()
    
    const isVisible = !this.dropdownTarget.classList.contains('hidden')
    
    if (isVisible) {
      this.hide()
    } else {
      this.show()
    }
  }
  
  show() {
    this.dropdownTarget.classList.remove('hidden')
    this.dropdownTarget.classList.add('block')
    
    // Add animation classes
    this.dropdownTarget.classList.add('opacity-100', 'translate-y-0')
    this.dropdownTarget.classList.remove('opacity-0', 'translate-y-2')
    
    // Update ARIA
    this.element.querySelector('button').setAttribute('aria-expanded', 'true')
  }
  
  hide() {
    this.dropdownTarget.classList.add('hidden')
    this.dropdownTarget.classList.remove('block')
    
    // Reset animation classes
    this.dropdownTarget.classList.remove('opacity-100', 'translate-y-0')
    this.dropdownTarget.classList.add('opacity-0', 'translate-y-2')
    
    // Update ARIA
    this.element.querySelector('button').setAttribute('aria-expanded', 'false')
  }
  
  handleClickOutside(event) {
    // Don't close if clicking within the dropdown controller
    if (this.element.contains(event.target)) return
    
    // Hide the dropdown if it's visible
    if (!this.dropdownTarget.classList.contains('hidden')) {
      this.hide()
    }
  }
  
  handleEscapeKey(event) {
    if (event.key === 'Escape' && !this.dropdownTarget.classList.contains('hidden')) {
      this.hide()
    }
  }
}
