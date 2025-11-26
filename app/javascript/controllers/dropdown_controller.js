import { Controller } from "@hotwired/stimulus"

// Simple, reliable dropdown controller
export default class extends Controller {
  static targets = ["menu", "button", "arrow"]

  connect() {
    console.log("🔵 Dropdown controller connected to:", this.element)
    console.log("   Menu target:", this.hasMenuTarget ? "found" : "NOT FOUND")
    console.log("   Button target:", this.hasButtonTarget ? "found" : "NOT FOUND")
    this.isOpen = false
    this.handleClickOutside = this.handleClickOutside.bind(this)
    this.handleKeydown = this.handleKeydown.bind(this)
  }

  disconnect() {
    this.removeGlobalListeners()
  }

  toggle(event) {
    console.log("🟡 Toggle called! isOpen:", this.isOpen)
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }

    if (this.isOpen) {
      console.log("📁 Closing dropdown...")
      this.close()
    } else {
      console.log("📂 Opening dropdown...")
      this.open()
    }
  }

  open() {
    // Close other dropdowns first
    this.closeOtherDropdowns()
    
    this.isOpen = true

    if (this.hasMenuTarget) {
      console.log("✅ Removing hidden class from menu")
      this.menuTarget.classList.remove("hidden")
      this.menuTarget.classList.remove("opacity-0", "scale-95")
      this.menuTarget.classList.add("opacity-100", "scale-100")
      console.log("Menu classes now:", this.menuTarget.className)
    }

    if (this.hasArrowTarget) {
      this.arrowTarget.classList.add("rotate-180")
    }

    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", "true")
    }

    // Delayed listener attachment to prevent immediate close
    setTimeout(() => {
      document.addEventListener("click", this.handleClickOutside)
      document.addEventListener("keydown", this.handleKeydown)
    }, 100)
  }

  close() {
    console.log("📁 Close called")
    this.isOpen = false

    if (this.hasMenuTarget) {
      this.menuTarget.classList.add("hidden")
      this.menuTarget.classList.add("opacity-0", "scale-95")
      this.menuTarget.classList.remove("opacity-100", "scale-100")
    }

    if (this.hasArrowTarget) {
      this.arrowTarget.classList.remove("rotate-180")
    }

    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", "false")
    }

    this.removeGlobalListeners()
  }

  closeOtherDropdowns() {
    document.querySelectorAll('[data-controller~="dropdown"]').forEach((el) => {
      if (el !== this.element) {
        const ctrl = this.application.getControllerForElementAndIdentifier(el, "dropdown")
        if (ctrl && ctrl.isOpen) ctrl.close()
      }
    })
  }

  handleClickOutside(event) {
    console.log("🔍 Click outside check:", event.target)
    if (!this.element.contains(event.target)) {
      console.log("❌ Click was outside, closing")
      this.close()
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close()
      if (this.hasButtonTarget) this.buttonTarget.focus()
    }
  }

  removeGlobalListeners() {
    document.removeEventListener("click", this.handleClickOutside)
    document.removeEventListener("keydown", this.handleKeydown)
  }
}
