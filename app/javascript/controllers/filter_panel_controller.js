import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "panel"]
  
  connect() {
    // Mobile handling
    this.originalDisplay = window.getComputedStyle(this.element).display
    this.updateVisibility()
    window.addEventListener('resize', this.updateVisibility.bind(this))
  }

  disconnect() {
    window.removeEventListener('resize', this.updateVisibility.bind(this))
  }
  
  updateVisibility() {
    // If we're on mobile, hide the panel initially
    if (window.innerWidth < 1024) { // lg breakpoint in Tailwind
      this.element.classList.add('hidden')
      this.element.classList.remove('lg:block')
    } else {
      this.element.classList.remove('hidden')
      this.element.classList.add('lg:block')
    }
  }
  
  toggle() {
    this.element.classList.toggle('hidden')
  }
  
  submit(event) {
    // Only auto-submit if it's a checkbox change
    if (event.target.type === 'checkbox') {
      this.submitForm()
    }
  }

  submitSort() {
    // Always submit when sort changes
    this.submitForm()
  }
  
  submitForm() {
    // To prevent multiple rapid submissions
    if (this.isSubmitting) return
    
    this.isSubmitting = true
    
    // Submit the form containing the filters after a small delay
    // to allow multiple changes
    clearTimeout(this.submitTimeout)
    this.submitTimeout = setTimeout(() => {
      if (this.hasFormTarget) {
        this.formTarget.requestSubmit()
      }
      this.isSubmitting = false
    }, 300)
  }
}
