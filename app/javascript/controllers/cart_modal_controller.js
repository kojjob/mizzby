import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "backdrop", "content"]
  
  connect() {
    // Close modal when clicking outside
    this.backdropClickHandler = this.closeOnBackdropClick.bind(this)
    
    // Close modal with escape key
    this.keydownHandler = this.handleKeydown.bind(this)
    
    // Initialize
    this.close()
  }
  
  disconnect() {
    document.removeEventListener('keydown', this.keydownHandler)
    if (this.hasBackdropTarget) {
      this.backdropTarget.removeEventListener('click', this.backdropClickHandler)
    }
  }
  
  open() {
    // Show the modal
    this.modalTarget.classList.remove('hidden')
    
    // Fade in animation
    setTimeout(() => {
      if (this.hasBackdropTarget) {
        this.backdropTarget.classList.add('opacity-50')
        this.backdropTarget.addEventListener('click', this.backdropClickHandler)
      }
      
      if (this.hasContentTarget) {
        this.contentTarget.classList.remove('translate-y-8', 'opacity-0')
        this.contentTarget.classList.add('translate-y-0', 'opacity-100')
      }
    }, 10)
    
    // Prevent body scrolling
    document.body.classList.add('overflow-hidden')
    
    // Add keyboard listener
    document.addEventListener('keydown', this.keydownHandler)
    
    // Load cart content if needed
    this.loadCartContent()
  }
  
  close() {
    // Start fade out animation
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.remove('opacity-50')
      this.backdropTarget.removeEventListener('click', this.backdropClickHandler)
    }
    
    if (this.hasContentTarget) {
      this.contentTarget.classList.add('translate-y-8', 'opacity-0')
      this.contentTarget.classList.remove('translate-y-0', 'opacity-100')
    }
    
    // Hide the modal after animation completes
    setTimeout(() => {
      this.modalTarget.classList.add('hidden')
    }, 300)
    
    // Restore body scrolling
    document.body.classList.remove('overflow-hidden')
    
    // Remove keyboard listener
    document.removeEventListener('keydown', this.keydownHandler)
  }
  
  closeOnBackdropClick(event) {
    if (event.target === this.backdropTarget) {
      this.close()
    }
  }
  
  handleKeydown(event) {
    if (event.key === 'Escape') {
      this.close()
    }
  }
  
  toggle(event) {
    if (event) event.preventDefault()
    
    if (this.modalTarget.classList.contains('hidden')) {
      this.open()
    } else {
      this.close()
    }
  }
  
  loadCartContent() {
    // We can implement AJAX loading here if needed
    // This could fetch the latest cart data without a page reload
  }
  
  // Handle quantity changes
  incrementQuantity(event) {
    const input = event.target.parentElement.querySelector('input')
    input.value = parseInt(input.value) + 1
    // You might want to add an AJAX call here to update the server
  }
  
  decrementQuantity(event) {
    const input = event.target.parentElement.querySelector('input')
    const currentValue = parseInt(input.value)
    if (currentValue > 1) {
      input.value = currentValue - 1
      // You might want to add an AJAX call here to update the server
    }
  }
  
  // Remove item from cart
  removeItem(event) {
    // You might want to add an AJAX call here to remove the item on the server
    const itemElement = event.target.closest('[data-cart-item]')
    if (itemElement) {
      itemElement.classList.add('opacity-0')
      setTimeout(() => {
        itemElement.remove()
        this.updateTotals()
      }, 300)
    }
  }
  
  // Update cart totals
  updateTotals() {
    // This would calculate new totals based on items in cart
    // For now, this is a placeholder
  }
}
