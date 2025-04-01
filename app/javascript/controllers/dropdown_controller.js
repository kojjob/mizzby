import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  
  connect() {
    // Close dropdown when clicking outside
    document.addEventListener('click', this.closeIfClickedOutside.bind(this))
  }
  
  disconnect() {
    document.removeEventListener('click', this.closeIfClickedOutside.bind(this))
  }
  
  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle('opacity-0')
    this.menuTarget.classList.toggle('invisible')
    this.menuTarget.classList.toggle('-translate-y-2')
    this.menuTarget.classList.toggle('translate-y-0')
  }
  
  closeIfClickedOutside(event) {
    if (!this.element.contains(event.target) && !this.menuTarget.classList.contains('opacity-0')) {
      this.menuTarget.classList.add('opacity-0', 'invisible', '-translate-y-2')
      this.menuTarget.classList.remove('translate-y-0')
    }
  }
}
