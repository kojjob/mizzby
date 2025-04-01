import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Auto-dismiss flash messages after 5 seconds (5000ms)
    this.dismissTimeout = setTimeout(() => {
      this.dismiss()
    }, 5000)
  }

  disconnect() {
    // Clear the timeout if the element is removed from the DOM
    if (this.dismissTimeout) {
      clearTimeout(this.dismissTimeout)
    }
  }

  dismiss() {
    // Fade out and then remove the element
    this.element.style.transition = "opacity 0.5s ease"
    this.element.style.opacity = 0
    
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }
}