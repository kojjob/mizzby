import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]
  
  connect() {
    this.isOpen = false
    
    // Add transition classes if not already present
    if (this.hasContentTarget) {
      this.contentTarget.style.transition = "max-height 300ms ease-in-out, opacity 150ms ease-in-out"
      this.contentTarget.style.overflow = "hidden"
    }
  }
  
  toggle() {
    this.isOpen ? this.close() : this.open()
  }
  
  open() {
    if (this.hasContentTarget) {
      // First remove hidden class
      this.contentTarget.classList.remove('hidden')
      
      // Force reflow for transition
      void this.contentTarget.offsetWidth
      
      // Set max height to a large value to allow animation
      const targetHeight = this.contentTarget.scrollHeight + 'px'
      this.contentTarget.style.maxHeight = targetHeight
      this.contentTarget.style.opacity = '1'
    }
    
    if (this.hasIconTarget) {
      this.iconTarget.classList.add('transform', 'rotate-180')
    }
    
    this.isOpen = true
  }
  
  close() {
    if (this.hasContentTarget) {
      // Animate out by setting max height to 0
      this.contentTarget.style.maxHeight = '0'
      this.contentTarget.style.opacity = '0'
      
      // After animation completes, add hidden class
      setTimeout(() => {
        if (!this.isOpen) {
          this.contentTarget.classList.add('hidden')
        }
      }, 300)
    }
    
    if (this.hasIconTarget) {
      this.iconTarget.classList.remove('rotate-180')
    }
    
    this.isOpen = false
  }
}
