import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button", "arrow"]

  connect() {
    this.clickOutside = this.clickOutside.bind(this)
    this.closeOnEscape = this.closeOnEscape.bind(this)
  }

  disconnect() {
    this.removeListeners()
  }

  toggle(event) {
    // We do NOT stop propagation here. 
    // This allows the click to bubble up to the document, 
    // which lets OTHER open dropdowns close themselves via their clickOutside listener.
    
    if (this.menuTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.menuTarget.classList.remove("hidden")
    if (this.hasArrowTarget) this.arrowTarget.classList.add("rotate-180")
    
    // Add listeners
    document.addEventListener("click", this.clickOutside)
    document.addEventListener("keydown", this.closeOnEscape)
  }

  close() {
    this.menuTarget.classList.add("hidden")
    if (this.hasArrowTarget) this.arrowTarget.classList.remove("rotate-180")
    this.removeListeners()
  }

  clickOutside(event) {
    // If the click is inside this dropdown controller (button or menu), ignore it.
    // The toggle action on the button handles the button click.
    // Clicks inside the menu should keep it open.
    if (this.element.contains(event.target)) {
      return
    }
    
    this.close()
  }
  
  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  removeListeners() {
    document.removeEventListener("click", this.clickOutside)
    document.removeEventListener("keydown", this.closeOnEscape)
  }
}