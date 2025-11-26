import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="wishlist-slideover"
export default class extends Controller {
  static targets = ["panel", "backdrop", "content"]

  connect() {
    console.log("Wishlist slideover controller connected")
    this.isOpen = false
    
    // Listen for custom events
    document.addEventListener("wishlist:toggle", this.toggle.bind(this))
    document.addEventListener("wishlist:open", this.open.bind(this))
    document.addEventListener("wishlist:close", this.close.bind(this))
    document.addEventListener("wishlist:updated", this.handleUpdate.bind(this))
    
    // Close on escape key
    document.addEventListener("keydown", this.handleKeydown.bind(this))
  }

  disconnect() {
    document.removeEventListener("wishlist:toggle", this.toggle.bind(this))
    document.removeEventListener("wishlist:open", this.open.bind(this))
    document.removeEventListener("wishlist:close", this.close.bind(this))
    document.removeEventListener("wishlist:updated", this.handleUpdate.bind(this))
    document.removeEventListener("keydown", this.handleKeydown.bind(this))
  }

  toggle() {
    console.log("Wishlist toggle called, isOpen:", this.isOpen)
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    console.log("Wishlist open called")
    this.isOpen = true
    
    // Enable pointer events on the container
    this.panelTarget.classList.remove("pointer-events-none")
    this.panelTarget.classList.add("pointer-events-auto")
    
    // Show backdrop with fade
    this.backdropTarget.classList.remove("opacity-0")
    this.backdropTarget.classList.add("opacity-100")
    
    // Slide in the panel
    this.contentTarget.classList.remove("translate-x-full")
    this.contentTarget.classList.add("translate-x-0")
    
    // Prevent body scroll
    document.body.style.overflow = "hidden"
    
    // Announce to screen readers
    this.panelTarget.setAttribute("aria-hidden", "false")
  }

  close() {
    console.log("Wishlist close called")
    this.isOpen = false
    
    // Hide backdrop
    this.backdropTarget.classList.remove("opacity-100")
    this.backdropTarget.classList.add("opacity-0")
    
    // Slide out panel
    this.contentTarget.classList.remove("translate-x-0")
    this.contentTarget.classList.add("translate-x-full")
    
    // Re-enable body scroll
    document.body.style.overflow = ""
    
    // After animation, disable pointer events
    setTimeout(() => {
      if (!this.isOpen) {
        this.panelTarget.classList.remove("pointer-events-auto")
        this.panelTarget.classList.add("pointer-events-none")
      }
    }, 300)
    
    // Announce to screen readers
    this.panelTarget.setAttribute("aria-hidden", "true")
  }

  closeOnBackdrop(event) {
    if (event.target === this.backdropTarget) {
      this.close()
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape" && this.isOpen) {
      this.close()
    }
  }

  handleUpdate(event) {
    console.log("Wishlist updated:", event.detail)
    // Could refresh the wishlist content here if needed
  }

  async removeItem(event) {
    const button = event.currentTarget
    const itemId = button.dataset.itemId
    const listItem = button.closest("[data-wishlist-item]")
    
    console.log("Removing wishlist item:", itemId)
    
    try {
      const response = await fetch(`/wishlist_items/${itemId}`, {
        method: "DELETE",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "application/json"
        }
      })
      
      if (response.ok) {
        // Animate removal
        listItem.style.opacity = "0"
        listItem.style.transform = "translateX(100%)"
        
        setTimeout(() => {
          listItem.remove()
          this.updateItemCount()
          
          // Check if wishlist is now empty
          const remainingItems = this.element.querySelectorAll("[data-wishlist-item]")
          if (remainingItems.length === 0) {
            location.reload()
          }
        }, 300)
        
        // Dispatch event for other components
        document.dispatchEvent(new CustomEvent("wishlist:updated", { detail: { action: "removed", itemId } }))
      }
    } catch (error) {
      console.error("Error removing wishlist item:", error)
    }
  }

  async moveToCart(event) {
    const button = event.currentTarget
    const productId = button.dataset.productId
    const itemId = button.dataset.itemId
    const listItem = button.closest("[data-wishlist-item]")
    
    console.log("Moving to cart, item:", itemId)
    
    // Disable button and show loading
    button.disabled = true
    const originalContent = button.innerHTML
    button.innerHTML = `
      <svg class="animate-spin h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      Adding...
    `
    
    try {
      // Use the move_to_cart endpoint which handles both adding to cart and removing from wishlist
      const response = await fetch(`/wishlist_items/${itemId}/move_to_cart`, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "application/json"
        }
      })
      
      const data = await response.json()
      
      if (response.ok && data.success) {
        // Animate removal
        listItem.style.opacity = "0"
        listItem.style.transform = "translateX(100%)"
        
        setTimeout(() => {
          listItem.remove()
          this.updateItemCount()
          
          // Update cart count in header
          this.updateCartCount(data.cart_count)
          
          // Check if wishlist is now empty
          const remainingItems = this.element.querySelectorAll("[data-wishlist-item]")
          if (remainingItems.length === 0) {
            location.reload()
          }
        }, 300)
        
        // Dispatch events
        document.dispatchEvent(new CustomEvent("wishlist:updated", { detail: { action: "moved", itemId } }))
        document.dispatchEvent(new CustomEvent("cart:updated", { detail: { action: "added", productId } }))
        
        // Show success notification
        this.showNotification(data.message || "Item moved to cart!", "success")
      } else {
        // Show error
        this.showNotification(data.message || "Could not move item to cart", "error")
        button.disabled = false
        button.innerHTML = originalContent
      }
    } catch (error) {
      console.error("Error moving item to cart:", error)
      this.showNotification("Something went wrong. Please try again.", "error")
      button.disabled = false
      button.innerHTML = originalContent
    }
  }

  updateCartCount(count) {
    const cartBadge = document.querySelector("[data-cart-count]")
    if (count > 0) {
      if (cartBadge) {
        cartBadge.textContent = count > 99 ? "99+" : count
      } else {
        // Create badge if it doesn't exist
        const cartButton = document.querySelector(".cart-toggle-btn")
        if (cartButton) {
          const badge = document.createElement("span")
          badge.setAttribute("data-cart-count", "")
          badge.className = "absolute -top-0.5 -right-0.5 h-4 w-4 bg-indigo-600 text-white text-xs font-bold rounded-full flex items-center justify-center ring-2 ring-gray-900 animate-pulse"
          badge.textContent = count > 99 ? "99+" : count
          cartButton.appendChild(badge)
        }
      }
    }
  }

  updateItemCount() {
    const countBadge = document.querySelector("[data-wishlist-count]")
    if (countBadge) {
      const currentCount = parseInt(countBadge.textContent) || 0
      const newCount = currentCount - 1
      
      if (newCount > 0) {
        countBadge.textContent = newCount > 99 ? "99+" : newCount
      } else {
        countBadge.remove()
      }
    }
    
    // Update slideover header count
    const headerCount = this.element.querySelector("[data-slideover-count]")
    if (headerCount) {
      const remainingItems = this.element.querySelectorAll("[data-wishlist-item]").length
      headerCount.textContent = `${remainingItems} ${remainingItems === 1 ? 'item' : 'items'}`
    }
  }

  showNotification(message, type = "success") {
    const notification = document.createElement("div")
    notification.className = `fixed bottom-4 right-4 z-[10000] px-6 py-3 rounded-xl shadow-lg transform transition-all duration-300 translate-y-full ${
      type === "success" ? "bg-green-500 text-white" : "bg-red-500 text-white"
    }`
    notification.textContent = message
    document.body.appendChild(notification)
    
    requestAnimationFrame(() => {
      notification.classList.remove("translate-y-full")
      notification.classList.add("translate-y-0")
    })
    
    setTimeout(() => {
      notification.classList.remove("translate-y-0")
      notification.classList.add("translate-y-full")
      setTimeout(() => notification.remove(), 300)
    }, 3000)
  }
}
