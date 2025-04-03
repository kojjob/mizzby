import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "leftShadow", "rightShadow"]
  
  connect() {
    this.checkScroll()
    this.containerTarget.addEventListener('scroll', this.checkScroll.bind(this))
  }
  
  disconnect() {
    this.containerTarget.removeEventListener('scroll', this.checkScroll.bind(this))
  }
  
  checkScroll() {
    const { scrollLeft, scrollWidth, clientWidth } = this.containerTarget
    
    // Show/hide left shadow based on scroll position
    if (scrollLeft > 0) {
      this.leftShadowTarget.classList.remove('opacity-0')
    } else {
      this.leftShadowTarget.classList.add('opacity-0')
    }
    
    // Show/hide right shadow based on scroll position
    if (scrollLeft + clientWidth < scrollWidth - 1) {
      this.rightShadowTarget.classList.remove('opacity-0')
    } else {
      this.rightShadowTarget.classList.add('opacity-0')
    }
  }
}