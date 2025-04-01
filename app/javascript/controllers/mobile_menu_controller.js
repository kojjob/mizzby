import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "openIcon", "closeIcon"]

  connect() {
    // Make sure we start with the menu closed
    this.close()
    
    // Add event listener for screen resize to close menu on large screens
    window.addEventListener("resize", this.handleResize.bind(this))
  }
  
  disconnect() {
    window.removeEventListener("resize", this.handleResize.bind(this))
  }

  toggle() {
    if (this.menuTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }
  
  open() {
    // Show the menu
    this.menuTarget.classList.remove("hidden")
    
    // Toggle icon visibility
    if (this.hasOpenIconTarget) this.openIconTarget.classList.add("hidden")
    if (this.hasCloseIconTarget) this.closeIconTarget.classList.remove("hidden")
    
    // Force reflow
    void this.menuTarget.offsetWidth
    
    // Animate in
    this.menuTarget.classList.add("max-h-screen", "opacity-100")
    this.menuTarget.classList.remove("max-h-0", "opacity-0")
    
    // Add document click listener
    document.addEventListener("click", this.clickOutside)
  }
  
  close() {
    // Animate out
    this.menuTarget.classList.remove("max-h-screen", "opacity-100")
    this.menuTarget.classList.add("max-h-0", "opacity-0")
    
    // Toggle icon visibility
    if (this.hasOpenIconTarget) this.openIconTarget.classList.remove("hidden")
    if (this.hasCloseIconTarget) this.closeIconTarget.classList.add("hidden")
    
    // After animation, hide completely
    setTimeout(() => {
      this.menuTarget.classList.add("hidden")
    }, 300)
    
    // Remove document click listener
    document.removeEventListener("click", this.clickOutside)
  }
  
  clickOutside = (event) => {
    // Close if clicking outside the menu and the toggle button
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
  
  handleResize() {
    // Close menu when resizing to desktop view
    if (window.innerWidth >= 768) {
      this.close()
    }
  }
}
