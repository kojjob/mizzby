import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "backdrop", "content", "itemsContainer", "emptyState", "cartCount", "subtotal", "total"]
  static values = { open: Boolean }
  
  connect() {
    console.log("Cart slideover controller connected")
    this.openValue = false
    
    // Close on escape key
    this.boundKeydown = this.handleKeydown.bind(this)
    document.addEventListener('keydown', this.boundKeydown)
    
    // Listen for cart update events
    this.boundCartUpdate = this.handleCartUpdate.bind(this)
    document.addEventListener('cart:updated', this.boundCartUpdate)
    
    // Listen for cart open event (triggered after adding item)
    this.boundCartOpen = this.open.bind(this)
    document.addEventListener('cart:open', this.boundCartOpen)
    
    // Listen for cart toggle event (triggered by header button)
    this.boundCartToggle = this.toggle.bind(this)
    document.addEventListener('cart:toggle', this.boundCartToggle)
  }
  
  disconnect() {
    document.removeEventListener('keydown', this.boundKeydown)
    document.removeEventListener('cart:updated', this.boundCartUpdate)
    document.removeEventListener('cart:open', this.boundCartOpen)
    document.removeEventListener('cart:toggle', this.boundCartToggle)
  }
  
  open(event) {
    console.log("Cart slideover open() called")
    if (event) event.preventDefault()
    this.openValue = true
    
    console.log("Panel target:", this.panelTarget)
    console.log("Backdrop target:", this.backdropTarget)
    console.log("Content target:", this.contentTarget)
    
    // Show panel
    this.panelTarget.classList.remove('pointer-events-none')
    
    // Animate backdrop
    requestAnimationFrame(() => {
      this.backdropTarget.classList.remove('opacity-0')
      this.backdropTarget.classList.add('opacity-100')
      
      // Slide in content
      this.contentTarget.classList.remove('translate-x-full')
      this.contentTarget.classList.add('translate-x-0')
    })
    
    // Prevent body scroll
    document.body.classList.add('overflow-hidden')
    
    // Refresh cart content
    this.refreshCart()
  }
  
  close(event) {
    console.log("Cart slideover close() called")
    if (event) event.preventDefault()
    this.openValue = false
    
    // Animate out
    this.backdropTarget.classList.remove('opacity-100')
    this.backdropTarget.classList.add('opacity-0')
    
    this.contentTarget.classList.remove('translate-x-0')
    this.contentTarget.classList.add('translate-x-full')
    
    // Hide panel after animation
    setTimeout(() => {
      this.panelTarget.classList.add('pointer-events-none')
    }, 300)
    
    // Restore body scroll
    document.body.classList.remove('overflow-hidden')
  }
  
  toggle(event) {
    console.log("Cart slideover toggle() called, openValue:", this.openValue)
    if (this.openValue) {
      this.close(event)
    } else {
      this.open(event)
    }
  }
  
  handleKeydown(event) {
    if (event.key === 'Escape' && this.openValue) {
      this.close()
    }
  }
  
  closeOnBackdrop(event) {
    if (event.target === this.backdropTarget) {
      this.close()
    }
  }
  
  async refreshCart() {
    try {
      const response = await fetch('/cart.json', {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        },
        credentials: 'same-origin'
      })
      
      if (response.ok) {
        const data = await response.json()
        this.updateCartDisplay(data)
      }
    } catch (error) {
      console.error('Error refreshing cart:', error)
    }
  }
  
  updateCartDisplay(data) {
    // Update cart count badges
    const countBadges = document.querySelectorAll('[data-cart-count]')
    countBadges.forEach(badge => {
      if (data.item_count > 0) {
        badge.textContent = data.item_count > 99 ? '99+' : data.item_count
        badge.classList.remove('hidden')
      } else {
        badge.classList.add('hidden')
      }
    })
  }
  
  handleCartUpdate(event) {
    this.refreshCart()
  }
  
  async updateQuantity(event) {
    const input = event.target
    const itemId = input.dataset.itemId
    const quantity = parseInt(input.value)
    
    if (quantity < 1) {
      input.value = 1
      return
    }
    
    try {
      const response = await fetch(`/cart_items/${itemId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ cart_item: { quantity: quantity } }),
        credentials: 'same-origin'
      })
      
      if (response.ok) {
        this.refreshCart()
        document.dispatchEvent(new CustomEvent('cart:updated'))
      }
    } catch (error) {
      console.error('Error updating quantity:', error)
    }
  }
  
  incrementQuantity(event) {
    const button = event.currentTarget
    const input = button.parentElement.querySelector('input')
    input.value = parseInt(input.value) + 1
    input.dispatchEvent(new Event('change', { bubbles: true }))
  }
  
  decrementQuantity(event) {
    const button = event.currentTarget
    const input = button.parentElement.querySelector('input')
    const currentValue = parseInt(input.value)
    if (currentValue > 1) {
      input.value = currentValue - 1
      input.dispatchEvent(new Event('change', { bubbles: true }))
    }
  }
  
  async removeItem(event) {
    event.preventDefault()
    const button = event.currentTarget
    const itemId = button.dataset.itemId
    const itemElement = button.closest('[data-cart-item]')
    
    // Animate out
    itemElement.classList.add('opacity-0', 'transform', '-translate-x-full')
    
    try {
      const response = await fetch(`/cart_items/${itemId}`, {
        method: 'DELETE',
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        credentials: 'same-origin'
      })
      
      if (response.ok) {
        setTimeout(() => {
          itemElement.remove()
          this.refreshCart()
          document.dispatchEvent(new CustomEvent('cart:updated'))
        }, 300)
      }
    } catch (error) {
      console.error('Error removing item:', error)
      itemElement.classList.remove('opacity-0', 'transform', '-translate-x-full')
    }
  }
}
