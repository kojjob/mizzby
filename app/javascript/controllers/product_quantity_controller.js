import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  
  connect() {
    this.updateInputAttributes()
  }
  
  increment(event) {
    event.preventDefault()
    const currentValue = parseInt(this.inputTarget.value)
    const maxValue = parseInt(this.inputTarget.getAttribute('max'))
    
    if (currentValue < maxValue) {
      this.inputTarget.value = currentValue + 1
    }
  }
  
  decrement(event) {
    event.preventDefault()
    const currentValue = parseInt(this.inputTarget.value)
    const minValue = parseInt(this.inputTarget.getAttribute('min'))
    
    if (currentValue > minValue) {
      this.inputTarget.value = currentValue - 1
    }
  }
  
  updateInputAttributes() {
    // Ensure min/max are enforced
    const minValue = parseInt(this.inputTarget.getAttribute('min'))
    const maxValue = parseInt(this.inputTarget.getAttribute('max'))
    
    let value = parseInt(this.inputTarget.value)
    
    if (value < minValue) {
      this.inputTarget.value = minValue
    } else if (value > maxValue) {
      this.inputTarget.value = maxValue
    }
  }
}