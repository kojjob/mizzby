import { Controller } from "@hotwired/stimulus"

// Navbar controller for mobile menu toggle
export default class extends Controller {
  static targets = ["mobileMenu", "menuIcon", "closeIcon", "mobileButton"]

  connect() {
    this.isOpen = false
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener("resize", this.handleResize)
  }

  disconnect() {
    window.removeEventListener("resize", this.handleResize)
  }

  toggleMobile(event) {
    event.preventDefault()
    event.stopPropagation()
    
    this.isOpen = !this.isOpen
    
    if (this.isOpen) {
      this.showMobileMenu()
    } else {
      this.hideMobileMenu()
    }
  }

  showMobileMenu() {
    if (this.hasMobileMenuTarget) {
      this.mobileMenuTarget.classList.remove("hidden")
    }
    if (this.hasMenuIconTarget) {
      this.menuIconTarget.classList.add("hidden")
    }
    if (this.hasCloseIconTarget) {
      this.closeIconTarget.classList.remove("hidden")
    }
    document.body.classList.add("overflow-hidden")
  }

  hideMobileMenu() {
    if (this.hasMobileMenuTarget) {
      this.mobileMenuTarget.classList.add("hidden")
    }
    if (this.hasMenuIconTarget) {
      this.menuIconTarget.classList.remove("hidden")
    }
    if (this.hasCloseIconTarget) {
      this.closeIconTarget.classList.add("hidden")
    }
    document.body.classList.remove("overflow-hidden")
    this.isOpen = false
  }

  handleResize() {
    // Close mobile menu on desktop viewport
    if (window.innerWidth >= 1024 && this.isOpen) {
      this.hideMobileMenu()
    }
  }
}
