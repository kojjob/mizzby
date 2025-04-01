import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "menu", "arrow"]
  static values = { 
    hover: { type: Boolean, default: false },
    delay: { type: Number, default: 150 }
  }

  connect() {
    this.open = false
    this.hoverTimeouts = { open: null, close: null }

    // Add transition classes if not already present
    if (this.hasMenuTarget) {
      this.menuTarget.classList.add("transform", "transition", "duration-150", "ease-out")
    }
    
    // Add arrow transition if arrow exists
    if (this.hasArrowTarget) {
      this.arrowTarget.classList.add("transition", "duration-150", "transform")
    }
    
    // Set up hover handling
    if (this.hoverValue) {
      this.element.addEventListener("mouseenter", this.mouseEnter.bind(this))
      this.element.addEventListener("mouseleave", this.mouseLeave.bind(this))
    }
    
    // Listen for clicks outside to close dropdown
    document.addEventListener("click", this.clickOutside.bind(this))
  }
  
  disconnect() {
    // Clean up event listeners
    document.removeEventListener("click", this.clickOutside.bind(this))
    
    if (this.hoverValue) {
      this.element.removeEventListener("mouseenter", this.mouseEnter.bind(this))
      this.element.removeEventListener("mouseleave", this.mouseLeave.bind(this))
    }
    
    // Clear any pending timeouts
    this.clearTimeouts()
  }
  
  toggle(event) {
    if (event) event.stopPropagation()
    this.open ? this.hideMenu() : this.showMenu()
  }
  
  clickOutside(event) {
    if (this.open && !this.element.contains(event.target)) {
      this.hideMenu()
    }
  }
  
  mouseEnter() {
    this.clearTimeouts()
    this.hoverTimeouts.open = setTimeout(() => {
      this.showMenu()
    }, this.delayValue)
  }
  
  mouseLeave() {
    this.clearTimeouts()
    this.hoverTimeouts.close = setTimeout(() => {
      this.hideMenu()
    }, this.delayValue * 1.5) // Slightly longer delay for closing
  }
  
  clearTimeouts() {
    if (this.hoverTimeouts.open) clearTimeout(this.hoverTimeouts.open)
    if (this.hoverTimeouts.close) clearTimeout(this.hoverTimeouts.close)
  }
  
  showMenu() {
    if (this.open) return

    if (this.hasMenuTarget) {
      // First make it visible but with opacity 0
      this.menuTarget.classList.remove('hidden')
      
      // Force a reflow to ensure the transition works
      void this.menuTarget.offsetWidth
      
      // Now animate it in
      this.menuTarget.classList.remove('opacity-0', 'scale-95', '-translate-y-2')
      this.menuTarget.classList.add('opacity-100', 'scale-100', 'translate-y-0')
    }
    
    if (this.hasArrowTarget) {
      this.arrowTarget.classList.add("rotate-180")
    }
    
    this.buttonTarget.setAttribute("aria-expanded", "true")
    this.open = true
    
    // Add the dropdown arrow element
    this.addDropdownArrow()
  }
  
  hideMenu() {
    if (!this.open) return
    
    if (this.hasMenuTarget) {
      // Animate out
      this.menuTarget.classList.remove('opacity-100', 'scale-100', 'translate-y-0')
      this.menuTarget.classList.add('opacity-0', 'scale-95', '-translate-y-2')
      
      // After animation completes, hide it
      setTimeout(() => {
        if (!this.open) {
          this.menuTarget.classList.add('hidden')
          this.removeDropdownArrow()
        }
      }, 150)
    }
    
    if (this.hasArrowTarget) {
      this.arrowTarget.classList.remove("rotate-180")
    }
    
    this.buttonTarget.setAttribute("aria-expanded", "false")
    this.open = false
  }
  
  addDropdownArrow() {
    // Remove any existing arrows first
    this.removeDropdownArrow()
    
    // Create and add the arrow element
    if (this.hasMenuTarget) {
      const arrow = document.createElement('div')
      arrow.classList.add('dropdown-arrow')
      this.menuTarget.appendChild(arrow)
      
      // Position the arrow based on button position
      const buttonRect = this.buttonTarget.getBoundingClientRect()
      const menuRect = this.menuTarget.getBoundingClientRect()
      
      // Center the arrow on the button
      arrow.style.left = `${buttonRect.left + (buttonRect.width / 2) - menuRect.left - 5}px`
    }
  }
  
  removeDropdownArrow() {
    if (this.hasMenuTarget) {
      const arrows = this.menuTarget.querySelectorAll('.dropdown-arrow')
      arrows.forEach(arrow => arrow.remove())
    }
  }
}
