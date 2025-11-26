import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="wishlist-toggle"
export default class extends Controller {
  static targets = ["button", "icon"]
  static values = { 
    productId: Number,
    inWishlist: Boolean
  }

  connect() {
    console.log("Wishlist toggle connected for product:", this.productIdValue, "inWishlist:", this.inWishlistValue)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    
    console.log("Toggle clicked, inWishlist:", this.inWishlistValue)
    
    // Check if already processing
    if (this.element.dataset.processing === "true") {
      console.log("Already processing, skipping")
      return
    }
    
    this.element.dataset.processing = "true"
    
    if (this.inWishlistValue) {
      this.removeFromWishlist()
    } else {
      this.addToWishlist()
    }
  }

  addToWishlist() {
    console.log("Adding product to wishlist:", this.productIdValue)
    
    fetch("/wishlist_items", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "application/json"
      },
      body: JSON.stringify({
        wishlist_item: { product_id: this.productIdValue }
      })
    })
    .then(response => {
      console.log("Add response status:", response.status)
      if (response.status === 401) {
        window.location.href = "/users/sign_in"
        return null
      }
      return response.json()
    })
    .then(data => {
      if (!data) return
      
      console.log("Add response data:", data)
      
      if (data.success) {
        this.inWishlistValue = true
        this.updateButtonState()
        this.updateWishlistCount(data.count)
        this.showNotification("Added to wishlist! ❤️", "success")
        document.dispatchEvent(new CustomEvent("wishlist:updated"))
      } else {
        this.showNotification(data.message || "Could not add to wishlist", "error")
      }
    })
    .catch(error => {
      console.error("Add to wishlist error:", error)
      this.showNotification("Something went wrong", "error")
    })
    .finally(() => {
      this.element.dataset.processing = "false"
    })
  }

  removeFromWishlist() {
    console.log("Removing product from wishlist:", this.productIdValue)
    
    fetch(`/wishlist_items/remove_by_product?product_id=${this.productIdValue}`, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "application/json"
      }
    })
    .then(response => {
      console.log("Remove response status:", response.status)
      if (response.status === 401) {
        window.location.href = "/users/sign_in"
        return null
      }
      return response.json()
    })
    .then(data => {
      if (!data) return
      
      console.log("Remove response data:", data)
      
      if (data.success) {
        this.inWishlistValue = false
        this.updateButtonState()
        this.updateWishlistCount(data.count)
        this.showNotification("Removed from wishlist", "success")
        document.dispatchEvent(new CustomEvent("wishlist:updated"))
      } else {
        this.showNotification(data.message || "Could not remove from wishlist", "error")
      }
    })
    .catch(error => {
      console.error("Remove from wishlist error:", error)
      this.showNotification("Something went wrong", "error")
    })
    .finally(() => {
      this.element.dataset.processing = "false"
    })
  }

  updateButtonState() {
    const button = this.hasButtonTarget ? this.buttonTarget : this.element.querySelector("button")
    const icon = this.hasIconTarget ? this.iconTarget : button?.querySelector("svg")
    
    if (!button) return
    
    console.log("Updating button state to:", this.inWishlistValue)
    
    if (this.inWishlistValue) {
      button.classList.add("text-red-500")
      button.classList.remove("text-gray-500", "text-gray-600")
      if (icon) icon.setAttribute("fill", "currentColor")
      button.title = "Remove from Wishlist"
    } else {
      button.classList.remove("text-red-500")
      button.classList.add("text-gray-500")
      if (icon) icon.setAttribute("fill", "none")
      button.title = "Add to Wishlist"
    }
  }

  updateWishlistCount(count) {
    console.log("Updating wishlist count to:", count)
    
    // Try multiple selectors to find the badge
    const badge = document.getElementById("wishlist-count-badge") || 
                  document.querySelector("[data-wishlist-count]") ||
                  document.querySelector(".wishlist-toggle-btn span")
    
    console.log("Found badge element:", badge)
    
    if (badge) {
      if (count > 0) {
        badge.textContent = count > 99 ? "99+" : count
        badge.classList.remove("hidden")
        console.log("Badge updated, now visible with count:", count)
      } else {
        badge.classList.add("hidden")
        console.log("Badge hidden (count is 0)")
      }
    } else {
      // Badge doesn't exist, try to create one
      const wishlistBtn = document.querySelector(".wishlist-toggle-btn")
      if (wishlistBtn && count > 0) {
        const newBadge = document.createElement("span")
        newBadge.id = "wishlist-count-badge"
        newBadge.setAttribute("data-wishlist-count", "")
        newBadge.className = "absolute -top-0.5 -right-0.5 h-4 w-4 bg-pink-500 text-white text-xs font-bold rounded-full flex items-center justify-center ring-2 ring-gray-900"
        newBadge.textContent = count > 99 ? "99+" : count
        wishlistBtn.appendChild(newBadge)
        console.log("Created new badge with count:", count)
      }
    }
  }

  showNotification(message, type = "success") {
    console.log("Showing notification:", message, type)
    
    // First, try the template-based approach for the standard flash system
    const flashContainer = document.getElementById("flash-container")
    const templateId = type === "success" ? "flash-template-success" : "flash-template-error"
    const template = document.getElementById(templateId)
    
    if (template && flashContainer) {
      console.log("Using template-based flash notification")
      const messageElement = template.content.cloneNode(true).firstElementChild
      const contentElement = messageElement.querySelector('.message-content')
      if (contentElement) {
        contentElement.textContent = message
      }
      flashContainer.prepend(messageElement)
      
      // Auto dismiss after 3 seconds
      setTimeout(() => {
        messageElement.classList.add('opacity-0', 'translate-x-full')
        setTimeout(() => messageElement.remove(), 300)
      }, 3000)
      return
    }
    
    // Fallback: Simple toast notification at bottom right
    console.log("Using fallback toast notification")
    document.querySelectorAll(".wishlist-notification").forEach(n => n.remove())
    
    const notification = document.createElement("div")
    notification.className = `wishlist-notification fixed bottom-4 right-4 z-[10000] px-6 py-3 rounded-xl shadow-lg ${
      type === "success" ? "bg-gradient-to-r from-pink-500 to-rose-500 text-white" : "bg-red-500 text-white"
    }`
    notification.textContent = message
    document.body.appendChild(notification)
    
    setTimeout(() => {
      notification.style.opacity = "0"
      setTimeout(() => notification.remove(), 300)
    }, 3000)
  }
}
