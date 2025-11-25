import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "openIcon", "closeIcon", "button"]

  connect() {
    console.log("✅ Mobile menu controller connected", this.element)
    this.isOpen = false
    
    // Bind methods
    this.handleEscape = this.handleEscape.bind(this)
    this.handleResize = this.handleResize.bind(this)
    
    // Add resize listener
    window.addEventListener("resize", this.handleResize)
  }

  disconnect() {
    window.removeEventListener("resize", this.handleResize)
    document.removeEventListener("keydown", this.handleEscape)
  }

  toggle(event) {
    console.log("🔄 Mobile menu toggle triggered")
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }

    if (this.isOpen) {
      this.hide()
    } else {
      this.show()
    }
  }

  show() {
    console.log("📂 Showing mobile menu")
    this.isOpen = true

    if (this.hasMenuTarget) {
      this.menuTarget.classList.remove("hidden")
    }

    if (this.hasOpenIconTarget && this.hasCloseIconTarget) {
      this.openIconTarget.classList.add("hidden")
      this.closeIconTarget.classList.remove("hidden")
    }

    // Prevent body scroll
    document.body.classList.add("overflow-hidden")
    
    // Listen for escape key
    document.addEventListener("keydown", this.handleEscape)
  }

  hide() {
    console.log("📁 Hiding mobile menu")
    this.isOpen = false

    if (this.hasMenuTarget) {
      this.menuTarget.classList.add("hidden")
    }

    if (this.hasOpenIconTarget && this.hasCloseIconTarget) {
      this.openIconTarget.classList.remove("hidden")
      this.closeIconTarget.classList.add("hidden")
    }

    // Allow body scroll again
    document.body.classList.remove("overflow-hidden")
    
    document.removeEventListener("keydown", this.handleEscape)
  }

  handleEscape(event) {
    if (event.key === "Escape" && this.isOpen) {
      this.hide()
    }
  }

  handleResize() {
    // Close mobile menu when resizing to desktop viewport
    if (window.innerWidth >= 768 && this.isOpen) {
      this.hide()
    }
  }
}