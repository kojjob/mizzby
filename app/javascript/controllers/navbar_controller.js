import { Controller } from "@hotwired/stimulus"

// Navbar controller for mobile menu toggle and badge updates
export default class extends Controller {
  static targets = ["mobileMenu", "menuIcon", "closeIcon", "mobileButton"]

  connect() {
    this.isOpen = false
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener("resize", this.handleResize)
    
    // Listen for cart and wishlist updates to refresh badges
    this.handleCartUpdate = this.refreshCartBadge.bind(this)
    this.handleWishlistUpdate = this.refreshWishlistBadge.bind(this)
    
    document.addEventListener("cart:updated", this.handleCartUpdate)
    document.addEventListener("wishlist:updated", this.handleWishlistUpdate)
    
    // Also listen for turbo:load to ensure badges are correct after navigation
    document.addEventListener("turbo:load", this.handleCartUpdate)
  }

  disconnect() {
    window.removeEventListener("resize", this.handleResize)
    document.removeEventListener("cart:updated", this.handleCartUpdate)
    document.removeEventListener("wishlist:updated", this.handleWishlistUpdate)
    document.removeEventListener("turbo:load", this.handleCartUpdate)
  }

  async refreshCartBadge() {
    try {
      const response = await fetch('/cart.json', {
        headers: { 'Accept': 'application/json' },
        credentials: 'same-origin'
      })
      
      if (response.ok) {
        const data = await response.json()
        const count = data.item_count || 0
        
        document.querySelectorAll('[data-cart-count]').forEach(badge => {
          if (count > 0) {
            badge.textContent = count > 99 ? '99+' : count
            badge.classList.remove('hidden')
          } else {
            badge.classList.add('hidden')
          }
        })
      }
    } catch (error) {
      console.error('Error refreshing cart badge:', error)
    }
  }

  async refreshWishlistBadge() {
    try {
      const response = await fetch('/wishlist_items.json', {
        headers: { 'Accept': 'application/json' },
        credentials: 'same-origin'
      })
      
      if (response.ok) {
        const data = await response.json()
        // data could be an array of items or an object with count
        const count = Array.isArray(data) ? data.length : (data.count || 0)
        
        const badge = document.getElementById('wishlist-count-badge') || document.querySelector('[data-wishlist-count]')
        if (badge) {
          if (count > 0) {
            badge.textContent = count > 99 ? '99+' : count
            badge.classList.remove('hidden')
          } else {
            badge.classList.add('hidden')
          }
        }
      }
    } catch (error) {
      console.error('Error refreshing wishlist badge:', error)
    }
  }
  }

  disconnect() {
    window.removeEventListener("resize", this.handleResize)
  }

  toggleMobile(event) {
    event.preventDefault()
    event.stopPropagation()
    
    this.isOpen = !this.isOpen
    
    if (this.isOpen) {
      this.showMobileMenu()
    } else {
      this.hideMobileMenu()
    }
  }

  showMobileMenu() {
    if (this.hasMobileMenuTarget) {
      this.mobileMenuTarget.classList.remove("hidden")
    }
    if (this.hasMenuIconTarget) {
      this.menuIconTarget.classList.add("hidden")
    }
    if (this.hasCloseIconTarget) {
      this.closeIconTarget.classList.remove("hidden")
    }
    document.body.classList.add("overflow-hidden")
  }

  hideMobileMenu() {
    if (this.hasMobileMenuTarget) {
      this.mobileMenuTarget.classList.add("hidden")
    }
    if (this.hasMenuIconTarget) {
      this.menuIconTarget.classList.remove("hidden")
    }
    if (this.hasCloseIconTarget) {
      this.closeIconTarget.classList.add("hidden")
    }
    document.body.classList.remove("overflow-hidden")
    this.isOpen = false
  }

  handleResize() {
    // Close mobile menu on desktop viewport
    if (window.innerWidth >= 1024 && this.isOpen) {
      this.hideMobileMenu()
    }
  }
}
