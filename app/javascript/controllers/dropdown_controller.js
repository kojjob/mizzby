import { Controller } from "@hotwired/stimulus"

// A unified dropdown controller that handles all dropdown functionality
export default class extends Controller {
  static targets = ["button", "menu", "arrow"]

  connect() {
    // Store the bound function reference so we can properly remove it later
    this.boundHideHandler = this.hide.bind(this)

    // Add outside click handler with a slight delay to prevent immediate closing
    // when the dropdown is first opened
    setTimeout(() => {
      document.addEventListener("click", this.boundHideHandler)
    }, 100)

    // Handle escape key to close dropdown
    this.boundKeyHandler = this.handleKeyDown.bind(this)
    document.addEventListener("keydown", this.boundKeyHandler)
  }

  disconnect() {
    // Clean up event listeners using the stored bound function references
    document.removeEventListener("click", this.boundHideHandler)
    document.removeEventListener("keydown", this.boundKeyHandler)
  }

  toggle(event) {
    if (event) {
      event.stopPropagation()
    }

    if (this.isOpen()) {
      this.hide()
    } else {
      this.show()
    }
  }

  show() {
    // Close all other dropdowns first
    document.querySelectorAll("[data-dropdown-menu], [data-dropdown-target='menu']").forEach(menu => {
      if (menu !== this.menuTarget) {
        menu.classList.add("hidden")
        menu.classList.remove("active")
      }
    })

    // Now show this dropdown
    this.menuTarget.classList.remove("hidden")

    // Add dropdown-menu class for styling
    this.menuTarget.classList.add("dropdown-menu")

    // Use setTimeout to ensure the transition works
    setTimeout(() => {
      this.menuTarget.classList.add("active")
    }, 10)

    // Rotate arrow if it exists
    if (this.hasArrowTarget) {
      this.arrowTarget.classList.add("transform", "rotate-180")
    }

    // Ensure the dropdown is fully visible on screen
    this.ensureVisibleOnScreen()

    // Add a backdrop for mobile
    if (window.innerWidth < 768) {
      this.createBackdrop()
    }
  }

  hide(event) {
    // Don't hide if the click was inside this controller element
    if (event && this.element.contains(event.target) && event.target !== document) {
      return
    }

    // Remove active class first (for animation)
    this.menuTarget.classList.remove("active")

    // Wait for animation to complete before hiding
    setTimeout(() => {
      this.menuTarget.classList.add("hidden")
    }, 200)

    // Reset arrow rotation
    if (this.hasArrowTarget) {
      this.arrowTarget.classList.remove("transform", "rotate-180")
    }

    // Remove backdrop if it exists
    this.removeBackdrop()
  }

  // Handle keyboard events
  handleKeyDown(event) {
    if (event.key === "Escape" && this.isOpen()) {
      this.hide()
    }
  }

  // Ensure the dropdown is fully visible on screen
  ensureVisibleOnScreen() {
    const rect = this.menuTarget.getBoundingClientRect()
    const windowWidth = window.innerWidth
    const windowHeight = window.innerHeight

    // Check if dropdown extends beyond right edge of screen
    if (rect.right > windowWidth) {
      this.menuTarget.style.left = "auto"
      this.menuTarget.style.right = "0"
    }

    // Check if dropdown extends beyond bottom of screen
    if (rect.bottom > windowHeight) {
      // If it's a large dropdown, position it at the top of the screen with scrolling
      if (rect.height > windowHeight * 0.8) {
        this.menuTarget.style.top = "1rem"
        this.menuTarget.style.maxHeight = `${windowHeight - 2}px`
        this.menuTarget.style.overflowY = "auto"
      } else {
        // Otherwise, position it above the trigger
        this.menuTarget.style.top = "auto"
        this.menuTarget.style.bottom = "100%"
        this.menuTarget.style.marginBottom = "0.5rem"
      }
    }
  }

  isOpen() {
    return !this.menuTarget.classList.contains("hidden")
  }

  // Create a backdrop for mobile dropdowns
  createBackdrop() {
    // Remove any existing backdrop first
    this.removeBackdrop()

    // Create backdrop element
    const backdrop = document.createElement('div')
    backdrop.classList.add('fixed', 'inset-0', 'bg-black', 'bg-opacity-50', 'z-40', 'transition-opacity', 'duration-300')
    backdrop.id = 'dropdown-backdrop'

    // Add click handler to close dropdown when backdrop is clicked
    backdrop.addEventListener('click', () => this.hide())

    // Add to DOM
    document.body.appendChild(backdrop)

    // Animate in
    setTimeout(() => {
      backdrop.classList.add('opacity-100')
    }, 10)
  }

  // Remove the backdrop
  removeBackdrop() {
    const backdrop = document.getElementById('dropdown-backdrop')
    if (backdrop) {
      // Animate out
      backdrop.classList.remove('opacity-100')
      backdrop.classList.add('opacity-0')

      // Remove from DOM after animation
      setTimeout(() => {
        backdrop.remove()
      }, 300)
    }
  }
}